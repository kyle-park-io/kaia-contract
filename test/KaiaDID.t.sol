// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {KaiaDID} from "../src/KaiaDID.sol";

/// @title KaiaDID 컨트랙트 테스트
/// @dev KaiaDID 컨트랙트의 모든 기능을 테스트
contract KaiaDIDTest is Test {
    KaiaDID public kaiaDID;
    address public owner;
    address public user1;
    address public user2;

    // 테스트 데이터
    string constant NAME1 = unicode"김철수";
    string constant BIRTH_DATE1 = "1990-01-01";
    string constant ADDRESS1 = unicode"서울시 강남구 테헤란로 123";
    string constant PHONE1 = "010-1234-5678";

    string constant NAME2 = unicode"이영희";
    string constant BIRTH_DATE2 = "1995-05-15";
    string constant ADDRESS2 = unicode"부산시 해운대구 해운대로 456";
    string constant PHONE2 = "010-9876-5432";

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        kaiaDID = new KaiaDID();
    }

    /// @notice DID 생성 테스트
    function test_CreateDID() public {
        vm.prank(user1);
        kaiaDID.createDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);

        // DID 존재 확인
        assertTrue(kaiaDID.hasDID(user1));

        // DID 정보 확인
        vm.prank(user1);
        KaiaDID.DIDDocument memory doc = kaiaDID.getMyDID();
        assertEq(doc.name, NAME1);
        assertEq(doc.birthDate, BIRTH_DATE1);
        assertEq(doc.homeAddress, ADDRESS1);
        assertEq(doc.phone, PHONE1);
        assertTrue(doc.isActive);
        assertGt(doc.createdAt, 0);
        assertGt(doc.updatedAt, 0);
    }

    /// @notice 중복 DID 생성 실패 테스트
    function test_CreateDID_AlreadyExists() public {
        vm.startPrank(user1);
        kaiaDID.createDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);

        // 중복 생성 시도 시 실패해야 함
        vm.expectRevert(unicode"이미 등록된 DID가 있습니다");
        kaiaDID.createDID(NAME2, BIRTH_DATE2, ADDRESS2, PHONE2);
        vm.stopPrank();
    }

    /// @notice 빈 이름으로 DID 생성 실패 테스트
    function test_CreateDID_EmptyName() public {
        vm.prank(user1);
        vm.expectRevert(unicode"이름은 필수입니다");
        kaiaDID.createDID("", BIRTH_DATE1, ADDRESS1, PHONE1);
    }

    /// @notice 빈 생년월일로 DID 생성 실패 테스트
    function test_CreateDID_EmptyBirthDate() public {
        vm.prank(user1);
        vm.expectRevert(unicode"생년월일은 필수입니다");
        kaiaDID.createDID(NAME1, "", ADDRESS1, PHONE1);
    }

    /// @notice DID 업데이트 테스트
    function test_UpdateDID() public {
        // DID 생성
        vm.prank(user1);
        kaiaDID.createDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);

        // DID 업데이트
        string memory newAddress = unicode"서울시 서초구 서초대로 789";
        string memory newPhone = unicode"010-1111-2222";

        vm.prank(user1);
        kaiaDID.updateDID(NAME1, BIRTH_DATE1, newAddress, newPhone);

        // 업데이트된 정보 확인
        vm.prank(user1);
        KaiaDID.DIDDocument memory doc = kaiaDID.getMyDID();
        assertEq(doc.homeAddress, newAddress);
        assertEq(doc.phone, newPhone);
    }

    /// @notice 존재하지 않는 DID 업데이트 실패 테스트
    function test_UpdateDID_NotExists() public {
        vm.prank(user1);
        vm.expectRevert(unicode"존재하지 않는 DID입니다");
        kaiaDID.updateDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);
    }

    /// @notice DID 비활성화 테스트
    function test_DeactivateDID() public {
        // DID 생성
        vm.prank(user1);
        kaiaDID.createDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);

        // DID 비활성화
        vm.prank(user1);
        kaiaDID.deactivateDID();

        // 비활성화 확인
        assertFalse(kaiaDID.hasDID(user1));
    }

    /// @notice 존재하지 않는 DID 비활성화 실패 테스트
    function test_DeactivateDID_NotExists() public {
        vm.prank(user1);
        vm.expectRevert(unicode"존재하지 않는 DID입니다");
        kaiaDID.deactivateDID();
    }

    /// @notice 다른 사용자 DID 조회 테스트
    function test_GetDID() public {
        // user1의 DID 생성
        vm.prank(user1);
        kaiaDID.createDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);

        // user2가 user1의 DID 조회
        KaiaDID.DIDDocument memory doc = kaiaDID.getDID(user1);
        assertEq(doc.name, NAME1);
        assertEq(doc.birthDate, BIRTH_DATE1);
        assertEq(doc.homeAddress, ADDRESS1);
        assertEq(doc.phone, PHONE1);
    }

    /// @notice 존재하지 않는 DID 조회 실패 테스트
    function test_GetDID_NotExists() public {
        vm.expectRevert(unicode"존재하지 않는 DID입니다");
        kaiaDID.getDID(user1);
    }

    /// @notice 자신의 DID 조회 실패 테스트
    function test_GetMyDID_NotExists() public {
        vm.prank(user1);
        vm.expectRevert(unicode"등록된 DID가 없습니다");
        kaiaDID.getMyDID();
    }

    /// @notice 총 DID 수 조회 테스트
    function test_GetTotalDIDs() public {
        assertEq(kaiaDID.getTotalDIDs(), 0);

        // user1 DID 생성
        vm.prank(user1);
        kaiaDID.createDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);
        assertEq(kaiaDID.getTotalDIDs(), 1);

        // user2 DID 생성
        vm.prank(user2);
        kaiaDID.createDID(NAME2, BIRTH_DATE2, ADDRESS2, PHONE2);
        assertEq(kaiaDID.getTotalDIDs(), 2);

        // user1 DID 비활성화
        vm.prank(user1);
        kaiaDID.deactivateDID();
        assertEq(kaiaDID.getTotalDIDs(), 1);
    }

    /// @notice 모든 활성 DID 조회 테스트 (관리자만)
    function test_GetAllActiveDIDs() public {
        // user1, user2 DID 생성
        vm.prank(user1);
        kaiaDID.createDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);

        vm.prank(user2);
        kaiaDID.createDID(NAME2, BIRTH_DATE2, ADDRESS2, PHONE2);

        // 모든 활성 DID 조회
        address[] memory activeDIDs = kaiaDID.getAllActiveDIDs();
        assertEq(activeDIDs.length, 2);
        assertEq(activeDIDs[0], user1);
        assertEq(activeDIDs[1], user2);
    }

    /// @notice 권한 없는 사용자의 모든 DID 조회 실패 테스트
    function test_GetAllActiveDIDs_OnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert(unicode"소유자만 실행 가능합니다");
        kaiaDID.getAllActiveDIDs();
    }

    /// @notice 소유권 이전 테스트
    function test_TransferOwnership() public {
        assertEq(kaiaDID.owner(), owner);

        kaiaDID.transferOwnership(user1);
        assertEq(kaiaDID.owner(), user1);
    }

    /// @notice 권한 없는 사용자의 소유권 이전 실패 테스트
    function test_TransferOwnership_OnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert(unicode"소유자만 실행 가능합니다");
        kaiaDID.transferOwnership(user2);
    }

    /// @notice 유효하지 않은 주소로 소유권 이전 실패 테스트
    function test_TransferOwnership_InvalidAddress() public {
        vm.expectRevert(unicode"유효하지 않은 주소입니다");
        kaiaDID.transferOwnership(address(0));
    }

    /// @notice DID 생성 이벤트 테스트
    function test_DIDCreatedEvent() public {
        vm.expectEmit(true, false, false, true);
        emit KaiaDID.DIDCreated(user1, NAME1);

        vm.prank(user1);
        kaiaDID.createDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);
    }

    /// @notice DID 업데이트 이벤트 테스트
    function test_DIDUpdatedEvent() public {
        // DID 생성
        vm.prank(user1);
        kaiaDID.createDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);

        // 업데이트 이벤트 확인
        vm.expectEmit(true, false, false, true);
        emit KaiaDID.DIDUpdated(user1, NAME1);

        vm.prank(user1);
        kaiaDID.updateDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);
    }

    /// @notice DID 비활성화 이벤트 테스트
    function test_DIDDeactivatedEvent() public {
        // DID 생성
        vm.prank(user1);
        kaiaDID.createDID(NAME1, BIRTH_DATE1, ADDRESS1, PHONE1);

        // 비활성화 이벤트 확인
        vm.expectEmit(true, false, false, false);
        emit KaiaDID.DIDDeactivated(user1);

        vm.prank(user1);
        kaiaDID.deactivateDID();
    }
}
