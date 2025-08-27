// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Kaia DID 신분증 컨트랙트
/// @dev 개인정보와 지갑 주소를 매칭하는 탈중앙화 신원 관리 시스템
contract KaiaDID {
    // DID 문서 구조체
    struct DIDDocument {
        string name; // 이름
        string birthDate; // 생년월일
        string homeAddress; // 주소
        string phone; // 전화번호
        bool isActive; // 활성화 상태
        uint256 createdAt; // 생성 시간
        uint256 updatedAt; // 업데이트 시간
        uint256 expiresAt; // 만료 시간
    }

    // 주소별 DID 문서 매핑
    mapping(address => DIDDocument) public didDocuments;

    // 등록된 DID 주소 목록
    address[] public registeredAddresses;

    // 컨트랙트 소유자
    address public owner;

    // DID 유효기간 (5분 = 300초)
    uint256 public constant VALIDITY_PERIOD = 300;

    // 이벤트 정의
    event DIDCreated(address indexed user, string name);
    event DIDUpdated(address indexed user, string name);
    event DIDDeactivated(address indexed user);
    event DIDRenewed(address indexed user, uint256 newExpiresAt);
    event DIDExpired(address indexed user);

    // 생성자
    constructor() {
        owner = msg.sender;
    }

    // 소유자만 실행 가능한 modifier
    modifier onlyOwner() {
        require(msg.sender == owner, unicode"소유자만 실행 가능합니다");
        _;
    }

    // DID가 존재하는지 확인하는 modifier
    modifier didExists(address user) {
        require(didDocuments[user].isActive, unicode"존재하지 않는 DID입니다");
        _;
    }

    // DID가 만료되지 않았는지 확인하는 modifier
    modifier notExpired(address user) {
        require(
            didDocuments[user].expiresAt > block.timestamp,
            unicode"만료된 DID입니다"
        );
        _;
    }

    // DID가 존재하고 만료되지 않았는지 확인하는 modifier
    modifier validDID(address user) {
        require(didDocuments[user].isActive, unicode"존재하지 않는 DID입니다");
        require(
            didDocuments[user].expiresAt > block.timestamp,
            unicode"만료된 DID입니다"
        );
        _;
    }

    /// @notice 새로운 DID 생성
    /// @param _name 이름
    /// @param _birthDate 생년월일
    /// @param _homeAddress 주소
    /// @param _phone 전화번호
    function createDID(
        string memory _name,
        string memory _birthDate,
        string memory _homeAddress,
        string memory _phone
    ) external {
        require(
            !didDocuments[msg.sender].isActive,
            unicode"이미 등록된 DID가 있습니다"
        );
        require(bytes(_name).length > 0, unicode"이름은 필수입니다");
        require(bytes(_birthDate).length > 0, unicode"생년월일은 필수입니다");

        didDocuments[msg.sender] = DIDDocument({
            name: _name,
            birthDate: _birthDate,
            homeAddress: _homeAddress,
            phone: _phone,
            isActive: true,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            expiresAt: block.timestamp + VALIDITY_PERIOD
        });

        registeredAddresses.push(msg.sender);

        emit DIDCreated(msg.sender, _name);
    }

    /// @notice DID 정보 업데이트
    /// @param _name 이름
    /// @param _birthDate 생년월일
    /// @param _homeAddress 주소
    /// @param _phone 전화번호
    function updateDID(
        string memory _name,
        string memory _birthDate,
        string memory _homeAddress,
        string memory _phone
    ) external validDID(msg.sender) {
        require(bytes(_name).length > 0, unicode"이름은 필수입니다");
        require(bytes(_birthDate).length > 0, unicode"생년월일은 필수입니다");

        DIDDocument storage doc = didDocuments[msg.sender];
        doc.name = _name;
        doc.birthDate = _birthDate;
        doc.homeAddress = _homeAddress;
        doc.phone = _phone;
        doc.updatedAt = block.timestamp;

        emit DIDUpdated(msg.sender, _name);
    }

    /// @notice DID 비활성화
    function deactivateDID() external validDID(msg.sender) {
        didDocuments[msg.sender].isActive = false;
        didDocuments[msg.sender].updatedAt = block.timestamp;

        emit DIDDeactivated(msg.sender);
    }

    /// @notice 특정 주소의 DID 정보 조회
    /// @param user 조회할 사용자 주소
    /// @return DID 문서 정보
    function getDID(address user) external view returns (DIDDocument memory) {
        require(didDocuments[user].isActive, unicode"존재하지 않는 DID입니다");
        require(
            didDocuments[user].expiresAt > block.timestamp,
            unicode"만료된 DID입니다"
        );
        return didDocuments[user];
    }

    /// @notice 자신의 DID 정보 조회
    /// @return 자신의 DID 문서 정보
    function getMyDID() external view returns (DIDDocument memory) {
        require(
            didDocuments[msg.sender].isActive,
            unicode"등록된 DID가 없습니다"
        );
        require(
            didDocuments[msg.sender].expiresAt > block.timestamp,
            unicode"만료된 DID입니다"
        );
        return didDocuments[msg.sender];
    }

    /// @notice DID 존재 여부 확인
    /// @param user 확인할 사용자 주소
    /// @return DID 존재 여부
    function hasDID(address user) external view returns (bool) {
        return
            didDocuments[user].isActive &&
            didDocuments[user].expiresAt > block.timestamp;
    }

    /// @notice 등록된 총 DID 수 조회
    /// @return 등록된 DID 수
    function getTotalDIDs() external view returns (uint256) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < registeredAddresses.length; i++) {
            if (didDocuments[registeredAddresses[i]].isActive) {
                activeCount++;
            }
        }
        return activeCount;
    }

    /// @notice 등록된 모든 활성 DID 주소 조회 (관리자만)
    /// @return 활성 DID 주소 배열
    function getAllActiveDIDs()
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        address[] memory tempAddresses = new address[](
            registeredAddresses.length
        );
        uint256 activeCount = 0;

        for (uint256 i = 0; i < registeredAddresses.length; i++) {
            if (didDocuments[registeredAddresses[i]].isActive) {
                tempAddresses[activeCount] = registeredAddresses[i];
                activeCount++;
            }
        }

        // 활성 주소만 포함하는 배열 생성
        address[] memory activeAddresses = new address[](activeCount);
        for (uint256 i = 0; i < activeCount; i++) {
            activeAddresses[i] = tempAddresses[i];
        }

        return activeAddresses;
    }

    /// @notice DID 갱신 (유효기간 연장)
    function renewDID() external didExists(msg.sender) {
        didDocuments[msg.sender].expiresAt = block.timestamp + VALIDITY_PERIOD;
        didDocuments[msg.sender].updatedAt = block.timestamp;

        emit DIDRenewed(msg.sender, didDocuments[msg.sender].expiresAt);
    }

    /// @notice DID 만료 여부 확인
    /// @param user 확인할 사용자 주소
    /// @return 만료 여부 (true면 만료됨)
    function isExpired(address user) external view returns (bool) {
        if (!didDocuments[user].isActive) {
            return false; // 비활성 DID는 만료 체크 대상이 아님
        }
        return didDocuments[user].expiresAt <= block.timestamp;
    }

    /// @notice DID 남은 유효시간 조회
    /// @param user 확인할 사용자 주소
    /// @return 남은 시간 (초 단위, 만료된 경우 0)
    function getRemainingTime(address user) external view returns (uint256) {
        if (
            !didDocuments[user].isActive ||
            didDocuments[user].expiresAt <= block.timestamp
        ) {
            return 0;
        }
        return didDocuments[user].expiresAt - block.timestamp;
    }

    /// @notice 컨트랙트 소유자 변경 (현재 소유자만)
    /// @param newOwner 새로운 소유자 주소
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), unicode"유효하지 않은 주소입니다");
        owner = newOwner;
    }
}
