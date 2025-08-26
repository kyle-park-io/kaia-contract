// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Counter 컨트랙트
/// @dev 숫자를 저장하고 증가시키는 간단한 예제
contract Counter {
    uint256 public number;

    /// @notice 새로운 숫자로 설정
    /// @param newNumber 설정할 숫자
    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    /// @notice 숫자를 1 증가
    function increment() public {
        number++;
    }
}
