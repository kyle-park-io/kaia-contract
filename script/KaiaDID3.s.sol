// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {KaiaDID3} from "../src/KaiaDID3.sol";

contract KaiaDID3Script is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        
        vm.startBroadcast(deployerPrivateKey);

        KaiaDID3 kaiaDID3 = new KaiaDID3();
        
        console.log("=== KaiaDID3 Deployment Info ===");
        console.log("Contract Address:", address(kaiaDID3));
        console.log("Owner:", kaiaDID3.owner());
        console.log("Block Number:", block.number);
        console.log("Block Timestamp:", block.timestamp);
        console.log("Deployer:", msg.sender);
        console.log("===============================");

        vm.stopBroadcast();
    }
}
