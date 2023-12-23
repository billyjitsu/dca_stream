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

contract DCA {
    address public owner;
    address public proxyAddress;

    using SuperTokenV1Library for ISuperToken;

    mapping(address => bool) public accountList;

    constructor(address _owner) {
        owner = _owner;
    }

    function setProxyAddress(address _proxyAddress) public {
        if (msg.sender != owner) revert Unauthorized();
        proxyAddress = _proxyAddress;
    }

    function readDataFeed() public view returns (uint256, uint256) {
        (int224 value, uint256 timestamp) = IProxy(proxyAddress).read();
        //convert price to UINT256
        uint256 price = uint224(value);
        return (price, timestamp);
    }

    // Flow Rate - Wei/Sec Flow Rate = 10 * (10^18) / ((365/12) * 24 * 60 * 60)

    // uint256 monthlyUSDAmount = 100 * (10**18); // $100 in wei
    // uint256 ethPrice; // ETH price in USD, to be fetched from readDataFeed
    // uint256 monthlyETHAmount = monthlyUSDAmount / ethPrice; // Convert $100 to equivalent ETH
    // int96 ethFlowRate = int96(monthlyETHAmount / ((365 / 12) * 24 * 60 * 60)); // Convert to flow rate in wei/sec

    function updateEthFlowRate(ISuperToken token, address receiver) external {
        // Authorization checks
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        // Get the latest ETH/USD price
        (uint256 ethPrice,) = readDataFeed();

        // Check for zero or very low ETH price to prevent division by zero
        require(ethPrice > 0, "ETH price is too low");

        // Get the current flow rate coming in
        int96 currentFlowRateIn = getTheCurrentFlow(token, receiver);


        // Calculate the equivalent flow rate in ETH based on the current ETH price
        // Note: currentFlowRateIn represents the flow rate in the token's smallest unit per second
        // Convert the flow rate to a USD value, then convert it to the equivalent ETH value
        uint256 currentFlowRateInUSDValue = uint256(int256(currentFlowRateIn)) * ethPrice; // Flow rate in USD value
        uint256 flowRateInSecondsInETH = currentFlowRateInUSDValue / ethPrice; // Convert to ETH value

        // Ensure that the calculated flow rate fits within the range of int96
       // require(flowRateInSecondsInETH <= type(int96).max, "Flow rate is too high");

        // Convert to int96 in two steps
        int96 newFlowRate = int96(int256(flowRateInSecondsInETH));

        // Update the flow rate
        token.updateFlow(receiver, newFlowRate);
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
    function createFlowIntoContract(ISuperToken token, int96 flowRate) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.createFlowFrom(msg.sender, address(this), flowRate);
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
    function createFlowFromContract(ISuperToken token, address receiver, int96 flowRate) external {
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
