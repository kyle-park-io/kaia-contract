// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {KaiaDID} from "../src/KaiaDID.sol";

/// @title KaiaDID 배포 스크립트
/// @dev KaiaDID 컨트랙트를 Kaia 네트워크에 배포
contract KaiaDIDScript is Script {
    function setUp() public {}

    /// @notice KaiaDID 컨트랙트 배포
    function run() public {
        // 배포자 계정으로 시작
        vm.startBroadcast();

        // KaiaDID 컨트랙트 배포
        KaiaDID kaiaDID = new KaiaDID();

        console.log(unicode"KaiaDID 컨트랙트가 배포되었습니다:");
        console.log(unicode"주소:", address(kaiaDID));
        console.log(unicode"소유자:", kaiaDID.owner());

        vm.stopBroadcast();
    }
}
