// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {KaiaDID3} from "../src/KaiaDID3.sol";

contract KaiaDID3Test is Test {
    KaiaDID3 public kaiaDID3;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        kaiaDID3 = new KaiaDID3();
    }

    function test_CreateDID() public {
        vm.startPrank(user1);

        kaiaDID3.createDID(
            unicode"홍길동",
            "1990-01-01",
            unicode"서울시 강남구",
            "010-1234-5678"
        );

        KaiaDID3.DIDDocument memory did = kaiaDID3.getMyLatestDID();
        assertEq(did.name, unicode"홍길동");
        assertEq(did.birthDate, "1990-01-01");
        assertEq(did.homeAddress, unicode"서울시 강남구");
        assertEq(did.phone, "010-1234-5678");
        assertTrue(did.isActive);
        assertEq(did.version, 1);

        vm.stopPrank();
    }

    function test_CreateMultipleDIDsSameAddress() public {
        vm.startPrank(user1);

        // 첫 번째 DID 생성
        kaiaDID3.createDID(
            unicode"홍길동",
            "1990-01-01",
            unicode"서울시 강남구",
            "010-1234-5678"
        );

        // 두 번째 DID 생성 (같은 주소)
        kaiaDID3.createDID(
            unicode"홍길동2",
            "1990-01-02",
            unicode"서울시 강북구",
            "010-1234-5679"
        );

        // 최신 DID 확인
        KaiaDID3.DIDDocument memory latestDID = kaiaDID3.getMyLatestDID();
        assertEq(latestDID.name, unicode"홍길동2");
        assertEq(latestDID.version, 2);

        // 전체 이력 확인
        KaiaDID3.DIDDocument[] memory allDIDs = kaiaDID3.getMyAllDIDHistory();
        assertEq(allDIDs.length, 2);
        assertEq(allDIDs[0].name, unicode"홍길동");
        assertEq(allDIDs[0].version, 1);
        assertEq(allDIDs[1].name, unicode"홍길동2");
        assertEq(allDIDs[1].version, 2);

        vm.stopPrank();
    }

    function test_UpdateDID() public {
        vm.startPrank(user1);

        // 첫 번째 DID 생성
        kaiaDID3.createDID(
            unicode"홍길동",
            "1990-01-01",
            unicode"서울시 강남구",
            "010-1234-5678"
        );

        // DID 업데이트 (새로운 버전 생성)
        kaiaDID3.updateDID(
            unicode"홍길동_수정",
            "1990-01-01",
            unicode"서울시 서초구",
            "010-9876-5432"
        );

        // 최신 DID 확인
        KaiaDID3.DIDDocument memory latestDID = kaiaDID3.getMyLatestDID();
        assertEq(latestDID.name, unicode"홍길동_수정");
        assertEq(latestDID.homeAddress, unicode"서울시 서초구");
        assertEq(latestDID.phone, "010-9876-5432");
        assertEq(latestDID.version, 2);

        // 전체 버전 수 확인
        assertEq(kaiaDID3.getDIDVersionCount(user1), 2);

        vm.stopPrank();
    }

    function test_DeactivateLatestDID() public {
        vm.startPrank(user1);

        // 여러 DID 생성
        kaiaDID3.createDID(
            unicode"홍길동1",
            "1990-01-01",
            unicode"서울시 강남구",
            "010-1234-5678"
        );
        kaiaDID3.createDID(
            unicode"홍길동2",
            "1990-01-01",
            unicode"서울시 강북구",
            "010-1234-5679"
        );
        kaiaDID3.createDID(
            unicode"홍길동3",
            "1990-01-01",
            unicode"서울시 서초구",
            "010-1234-5680"
        );

        // 최신 DID 비활성화
        kaiaDID3.deactivateLatestDID();

        // 최신 활성 DID는 이제 버전 2가 되어야 함
        KaiaDID3.DIDDocument memory latestActiveDID = kaiaDID3.getMyLatestDID();
        assertEq(latestActiveDID.name, unicode"홍길동2");
        assertEq(latestActiveDID.version, 2);
        assertTrue(latestActiveDID.isActive);

        // 버전 3은 비활성화되어야 함
        KaiaDID3.DIDDocument memory deactivatedDID = kaiaDID3.getDIDByVersion(
            user1,
            3
        );
        assertFalse(deactivatedDID.isActive);

        vm.stopPrank();
    }

    function test_GetDIDByVersion() public {
        vm.startPrank(user1);

        kaiaDID3.createDID(
            unicode"홍길동1",
            "1990-01-01",
            unicode"서울시 강남구",
            "010-1234-5678"
        );
        kaiaDID3.createDID(
            unicode"홍길동2",
            "1990-01-02",
            unicode"서울시 강북구",
            "010-1234-5679"
        );
        kaiaDID3.createDID(
            unicode"홍길동3",
            "1990-01-03",
            unicode"서울시 서초구",
            "010-1234-5680"
        );

        // 특정 버전 조회
        KaiaDID3.DIDDocument memory version1 = kaiaDID3.getDIDByVersion(
            user1,
            1
        );
        KaiaDID3.DIDDocument memory version2 = kaiaDID3.getDIDByVersion(
            user1,
            2
        );
        KaiaDID3.DIDDocument memory version3 = kaiaDID3.getDIDByVersion(
            user1,
            3
        );

        assertEq(version1.name, unicode"홍길동1");
        assertEq(version1.version, 1);
        assertEq(version2.name, unicode"홍길동2");
        assertEq(version2.version, 2);
        assertEq(version3.name, unicode"홍길동3");
        assertEq(version3.version, 3);

        vm.stopPrank();
    }

    function test_HasActiveDID() public {
        vm.startPrank(user1);

        // 처음에는 DID가 없음
        assertFalse(kaiaDID3.hasActiveDIDPublic(user1));

        // DID 생성 후에는 true
        kaiaDID3.createDID(
            unicode"홍길동",
            "1990-01-01",
            unicode"서울시 강남구",
            "010-1234-5678"
        );
        assertTrue(kaiaDID3.hasActiveDIDPublic(user1));

        // 비활성화 후에는 false
        kaiaDID3.deactivateLatestDID();
        assertFalse(kaiaDID3.hasActiveDIDPublic(user1));

        vm.stopPrank();
    }

    function test_GetTotalCounts() public {
        vm.startPrank(user1);
        kaiaDID3.createDID(
            unicode"홍길동",
            "1990-01-01",
            unicode"서울시 강남구",
            "010-1234-5678"
        );
        vm.stopPrank();

        vm.startPrank(user2);
        kaiaDID3.createDID(
            unicode"김철수",
            "1995-05-05",
            unicode"부산시 해운대구",
            "010-9999-8888"
        );
        vm.stopPrank();

        // 총 활성 DID 수
        assertEq(kaiaDID3.getTotalActiveDIDs(), 2);

        // 총 등록된 주소 수
        assertEq(kaiaDID3.getTotalRegisteredAddresses(), 2);

        // user1의 DID 비활성화
        vm.prank(user1);
        kaiaDID3.deactivateLatestDID();

        // 활성 DID는 1개로 줄어야 함
        assertEq(kaiaDID3.getTotalActiveDIDs(), 1);

        // 하지만 등록된 주소는 여전히 2개
        assertEq(kaiaDID3.getTotalRegisteredAddresses(), 2);
    }

    function test_GetLatestDIDFromAnotherAddress() public {
        vm.startPrank(user1);
        kaiaDID3.createDID(
            unicode"홍길동",
            "1990-01-01",
            unicode"서울시 강남구",
            "010-1234-5678"
        );
        vm.stopPrank();

        // 다른 주소에서 조회
        vm.startPrank(user2);
        KaiaDID3.DIDDocument memory did = kaiaDID3.getLatestDID(user1);
        assertEq(did.name, unicode"홍길동");
        assertEq(did.version, 1);
        vm.stopPrank();
    }

    function test_FailCreateDIDWithoutName() public {
        vm.startPrank(user1);

        vm.expectRevert(unicode"이름은 필수입니다");
        kaiaDID3.createDID(
            "",
            "1990-01-01",
            unicode"서울시 강남구",
            "010-1234-5678"
        );

        vm.stopPrank();
    }

    function test_FailGetLatestDIDWhenNoDID() public {
        vm.startPrank(user1);

        vm.expectRevert(unicode"활성화된 DID가 없습니다");
        kaiaDID3.getMyLatestDID();

        vm.stopPrank();
    }

    function test_FailUpdateDIDWhenNoDID() public {
        vm.startPrank(user1);

        vm.expectRevert(unicode"활성화된 DID가 없습니다");
        kaiaDID3.updateDID(
            unicode"홍길동",
            "1990-01-01",
            unicode"서울시 강남구",
            "010-1234-5678"
        );

        vm.stopPrank();
    }

    function test_OnlyOwnerFunctions() public {
        vm.startPrank(user1);
        kaiaDID3.createDID(
            unicode"홍길동",
            "1990-01-01",
            unicode"서울시 강남구",
            "010-1234-5678"
        );
        vm.stopPrank();

        // 소유자가 아닌 사용자가 관리자 전용 함수 호출 시 실패
        vm.startPrank(user1);
        vm.expectRevert(unicode"소유자만 실행 가능합니다");
        kaiaDID3.getAllActiveDIDAddresses();

        vm.expectRevert(unicode"소유자만 실행 가능합니다");
        kaiaDID3.getAllRegisteredAddresses();
        vm.stopPrank();

        // 소유자는 성공
        address[] memory activeAddresses = kaiaDID3.getAllActiveDIDAddresses();
        address[] memory allAddresses = kaiaDID3.getAllRegisteredAddresses();

        assertEq(activeAddresses.length, 1);
        assertEq(allAddresses.length, 1);
        assertEq(activeAddresses[0], user1);
        assertEq(allAddresses[0], user1);
    }
}
