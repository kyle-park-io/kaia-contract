// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

/// @title Counter 배포 스크립트
/// @dev Counter 컨트랙트를 배포하는 스크립트
contract CounterScript is Script {
    Counter public counter;

    /// @notice 스크립트 초기 설정
    function setUp() public {}

    /// @notice Counter 컨트랙트 배포 실행
    function run() public {
        vm.startBroadcast();

        counter = new Counter();

        vm.stopBroadcast();
    }
}
