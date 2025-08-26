// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

/// @title Counter 테스트
/// @dev Counter 컨트랙트의 기능을 테스트
contract CounterTest is Test {
    Counter public counter;

    /// @notice 테스트 초기 설정
    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    /// @notice increment 함수 테스트
    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    /// @notice setNumber 함수 퍼즈 테스트
    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
