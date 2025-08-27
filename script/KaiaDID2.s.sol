// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {KaiaDID} from "../src/KaiaDID2.sol";

/// @title KaiaDID2 배포 스크립트
/// @dev KaiaDID2 컨트랙트를 Kaia 네트워크에 배포
contract KaiaDID2Script is Script {
    function setUp() public {}

    /// @notice KaiaDID2 컨트랙트 배포
    function run() public {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));
        
        vm.startBroadcast(deployerPrivateKey);

        // KaiaDID2 컨트랙트 배포
        KaiaDID kaiaDID2 = new KaiaDID();

        console.log("=== KaiaDID2 Deployment Info ===");
        console.log("Contract Address:", address(kaiaDID2));
        console.log("Owner:", kaiaDID2.owner());
        console.log("Block Number:", block.number);
        console.log("Block Timestamp:", block.timestamp);
        console.log("Deployer:", msg.sender);
        console.log("===============================");

        vm.stopBroadcast();
    }
}
