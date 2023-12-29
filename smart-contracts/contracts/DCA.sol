//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {
    ISuperfluid,
    ISuperToken,
    ISuperApp
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import {SuperTokenV1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";
import "@api3/contracts/v0.8/interfaces/IProxy.sol";

error Unauthorized();
error PriceStale();

// 0x96b82b65acf7072efeb00502f45757f254c2a0d4    // super maticx
// 0x42bb40bf79730451b11f6de1cba222f17b87afd7    // super usdc
// 3805175038051                                 // 10 usdc flow rate

contract DCA {
    uint256 private constant WEI_PER_ETH = 1e18;
    uint256 private constant SECONDS_PER_MONTH = 365 * 24 * 60 * 60 / 12;
    uint256 private constant USDC_DECIMALS = 1e6;

    address public owner;
    address public ethProxyAddress;
    address public usdcProxyAddress;

    int96 public publicCalculatedFlowRateIn;

    using SuperTokenV1Library for ISuperToken;

    mapping(address => bool) public accountList;

    constructor(address _owner) {
        owner = _owner;
    }

    function setProxyAddress(address _ethProxyAddress, address _usdcProxyAddress) public {
        if (msg.sender != owner) revert Unauthorized();
        ethProxyAddress = _ethProxyAddress;
        usdcProxyAddress = _usdcProxyAddress;
    }

    function readDataFeed(address _priceFeed) public view returns (uint256, uint256) {
        (int224 value, uint256 timestamp) = IProxy(_priceFeed).read();
        //convert price to UINT256
        uint256 price = uint224(value);
        return (price, timestamp);
    }

    // Flow Rate - Wei/Sec Flow Rate = 10 * (10^18) / ((365/12) * 24 * 60 * 60)

    // uint256 monthlyUSDAmount = 100 * (10**18); // $100 in wei
    // uint256 ethPrice; // ETH price in USD, to be fetched from readDataFeed
    // uint256 monthlyETHAmount = monthlyUSDAmount / ethPrice; // Convert $100 to equivalent ETH
    // int96 ethFlowRate = int96(monthlyETHAmount / ((365 / 12) * 24 * 60 * 60)); // Convert to flow rate in wei/sec

    // can be converted to handle more tokens via function passthrough
    function calculateFlowRate(ISuperToken token, address receiver) public view returns (int96){
        // Authorization checks
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        // Get the latest ETH/USD price
        (uint256 ethPrice,) = readDataFeed(ethProxyAddress);
        // example 2344120000000000000000
        (uint256 usdcPrice,) = readDataFeed(usdcProxyAddress);

        // Check for zero or very low ETH price to prevent division by zero
        if (ethPrice <= 0 || usdcPrice <= 0) revert PriceStale();

        // Get the current flow rate coming in
        int96 currentFlowRateIn = getTheCurrentFlow(token, receiver);
        //  10 bucks a month  3805175038052

        // reverse the amount
        // (3805175038052 * ((365 / 12) * 24 * 60 * 60))
        uint256 currentFlowRateInUsd = uint256(int256(currentFlowRateIn)) * SECONDS_PER_MONTH;
        // 10 (10^18)

        // make sure it's pegged
        // 10 (10e18) * usdcPrice / 10e18
        uint256 currentFlowRateInUsdPegged = (currentFlowRateInUsd * usdcPrice) / WEI_PER_ETH;

        // now we need to convert it to eth value
        //                      10 (10^18 ) / 2344120000000000000000
        // value to getin eth is it stays consisten
        uint256 valueToGetInEth = currentFlowRateInUsdPegged / ethPrice;
        // amount in ETH = (currentflowrate in dollars (10 now) / eth price)
        // = 0.004265993208544

        // now calculate the flow rate out base on this value
        //  0.004265993208544 * (10^18) / ((365/12) * 24 * 60 * 60)
        uint256 flowRateInSecondsInETH = (valueToGetInEth * WEI_PER_ETH) / SECONDS_PER_MONTH;
        // 1623285086

        // Ensure that the calculated flow rate fits within the range of int96
        // require(flowRateInSecondsInETH <= type(int96).max, "Flow rate is too high");

        // Convert to int96 in two steps
        int96 newFlowRate = int96(int256(flowRateInSecondsInETH));

        // should net me 4300000000000000 eth
        // roughly 1623285086
        // Update the flow rate

        //token.updateFlow(receiver, newFlowRate);
        return newFlowRate;
    }

    // Ownership functions
    function allowAccount(address _account) external {
        if (msg.sender != owner) revert Unauthorized();

        accountList[_account] = true;
    }

    function removeAccount(address _account) external {
        if (msg.sender != owner) revert Unauthorized();

        accountList[_account] = false;
    }

    function changeOwner(address _newOwner) external {
        if (msg.sender != owner) revert Unauthorized();

        owner = _newOwner;
    }

    // Stream into Contract Functions
    function createFlowIntoContract(ISuperToken token, ISuperToken _desiredToken, int96 flowRate) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.createFlowFrom(msg.sender, address(this), flowRate);
        //once stream in, stream out
        int96 payoutFlowRate = calculateFlowRate(token, msg.sender);
        publicCalculatedFlowRateIn = payoutFlowRate;
        createFlowFromContract(_desiredToken, msg.sender, payoutFlowRate);
    }

    function updateFlowIntoContract(ISuperToken token, int96 flowRate) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.updateFlowFrom(msg.sender, address(this), flowRate);
    }

    function deleteFlowIntoContract(ISuperToken token) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.deleteFlow(msg.sender, address(this));
    }

    function getTheCurrentFlow(ISuperToken token, address _receiver) public view returns (int96) {
        return token.getFlowRate(address(this), _receiver);
    }

    // Stream out from Contract Functions
    function createFlowFromContract(ISuperToken token, address receiver, int96 flowRate) public {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.createFlow(receiver, flowRate);
    }

    function updateFlowFromContract(ISuperToken token, address receiver, int96 flowRate) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.updateFlow(receiver, flowRate);
    }

    function deleteFlowFromContract(ISuperToken token, address receiver) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.deleteFlow(address(this), receiver);
    }

    // Fund the contract with tokens
    function sendLumpSumToContract(ISuperToken token, uint256 amount) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.transferFrom(msg.sender, address(this), amount);
    }

    // Pull tokens from contract
    function withdrawFunds(ISuperToken token, uint256 amount) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.transfer(msg.sender, amount);
    }
}
