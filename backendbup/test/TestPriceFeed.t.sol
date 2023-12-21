// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {PriceFeed} from "../contracts/PriceFeed.sol";
import {MockDapiProxy} from "../contracts/Mocks/MockDapi.sol";
import {DeployPriceFeed} from "../scripts/DeployPriceFeed.s.sol";
import {Test, console} from "forge-std/Test.sol";


contract TestPriceFeed is Test {
    PriceFeed public priceFeed;
    MockDapiProxy public mockDapi;

    function setUp() external {
        DeployPriceFeed deployer = new DeployPriceFeed();
        (mockDapi, priceFeed) = deployer.run();
    }
    
    /* to see logs "forge test -vv" for more tracing add more v's */
    function testOwner() public {
        // console.log("PriceFeed owner: %s", address(priceFeed.owner()));
        // console.log("Msg sender: %s", address(msg.sender));
        assertEq(priceFeed.owner(), msg.sender);
    }

    function testPriceFeed() public {
        int224 price = 100e18;
        uint256 expectedValue = 100e18;
        // Make sure only owner can set proxy address
        vm.expectRevert();
        priceFeed.setProxyAddress(address(mockDapi));
        // starting Prank ALL subsequent calls will come from msg.sender
        vm.startPrank(msg.sender);
        // setting a block time
        vm.warp(1692843154);
        mockDapi.setDapiValues(price, uint32(block.timestamp));
        priceFeed.setProxyAddress(address(mockDapi));
        vm.stopPrank();
        (uint a, uint b) = priceFeed.readDataFeed();
        console.log("PriceFeed Value", a);
        console.log("PriceFeed Timestamp", b);
       
        assertEq(expectedValue, a);
        assertEq(b, uint32(block.timestamp));
    }
}