// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {PriceFeed} from "../contracts/PriceFeed.sol";
import {MockDapiProxy} from "../contracts/Mocks/MockDapi.sol";

contract DeployPriceFeed is Script {
    function run() external returns (MockDapiProxy, PriceFeed) {
        vm.startBroadcast();
        PriceFeed priceFeed = new PriceFeed();
        MockDapiProxy mockDapiProxy = new MockDapiProxy();
        vm.stopBroadcast();
        return (mockDapiProxy, priceFeed);
    }
}


// Deployment line direct
//forge create --rpc-url $env:MUMBAI_RPC_URL --private-key $env:PRIVATE_KEY --etherscan-api-key $env:POLYGON_ETHERSCAN_API_KEY --verify  contracts/PriceFeed.sol:PriceFeed 