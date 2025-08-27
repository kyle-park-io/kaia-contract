// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Kaia DID 신분증 컨트랙트 v3
/// @dev 주소별 여러 DID 허용, 배열로 관리하며 최신값 기준으로 조회하는 탈중앙화 신원 관리 시스템
contract KaiaDID3 {
    // DID 문서 구조체
    struct DIDDocument {
        string name; // 이름
        string birthDate; // 생년월일
        string homeAddress; // 주소
        string phone; // 전화번호
        bool isActive; // 활성화 상태
        uint256 createdAt; // 생성 시간
        uint256 updatedAt; // 업데이트 시간
        uint256 version; // 버전 번호
    }

    // 주소별 DID 문서 배열 매핑 (중복 허용)
    mapping(address => DIDDocument[]) public didDocumentHistory;

    // 등록된 DID 주소 목록 (중복 제거용)
    address[] public registeredAddresses;
    mapping(address => bool) public hasRegistered;

    // 컨트랙트 소유자
    address public owner;

    // 이벤트 정의
    event DIDCreated(address indexed user, string name, uint256 version);
    event DIDUpdated(address indexed user, string name, uint256 version);
    event DIDDeactivated(address indexed user, uint256 version);

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
    modifier hasActiveDID(address user) {
        require(
            getLatestActiveDIDIndex(user) != type(uint256).max,
            unicode"활성화된 DID가 없습니다"
        );
        _;
    }

    /// @notice 내부 함수: 최신 활성화된 DID 인덱스 반환
    /// @param user 조회할 사용자 주소
    /// @return 최신 활성 DID 인덱스 (없으면 type(uint256).max)
    function getLatestActiveDIDIndex(
        address user
    ) internal view returns (uint256) {
        DIDDocument[] storage userDIDs = didDocumentHistory[user];
        if (userDIDs.length == 0) {
            return type(uint256).max;
        }

        // 뒤에서부터 검색하여 최신 활성 DID 찾기
        for (uint256 i = userDIDs.length; i > 0; i--) {
            if (userDIDs[i - 1].isActive) {
                return i - 1;
            }
        }
        return type(uint256).max;
    }

    /// @notice 새로운 DID 생성 (중복 허용)
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
        require(bytes(_name).length > 0, unicode"이름은 필수입니다");
        require(bytes(_birthDate).length > 0, unicode"생년월일은 필수입니다");

        uint256 newVersion = didDocumentHistory[msg.sender].length + 1;

        DIDDocument memory newDID = DIDDocument({
            name: _name,
            birthDate: _birthDate,
            homeAddress: _homeAddress,
            phone: _phone,
            isActive: true,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            version: newVersion
        });

        didDocumentHistory[msg.sender].push(newDID);

        // 처음 등록하는 주소인 경우에만 배열에 추가
        if (!hasRegistered[msg.sender]) {
            registeredAddresses.push(msg.sender);
            hasRegistered[msg.sender] = true;
        }

        emit DIDCreated(msg.sender, _name, newVersion);
    }

    /// @notice DID 정보 업데이트 (기존 DID 수정이 아닌 새로운 버전 생성)
    /// @param _name 이름
    /// @param _birthDate 생년월일
    /// @param _homeAddress 주소
    /// @param _phone 전화번호
    function updateDID(
        string memory _name,
        string memory _birthDate,
        string memory _homeAddress,
        string memory _phone
    ) external hasActiveDID(msg.sender) {
        require(bytes(_name).length > 0, unicode"이름은 필수입니다");
        require(bytes(_birthDate).length > 0, unicode"생년월일은 필수입니다");

        uint256 newVersion = didDocumentHistory[msg.sender].length + 1;

        DIDDocument memory updatedDID = DIDDocument({
            name: _name,
            birthDate: _birthDate,
            homeAddress: _homeAddress,
            phone: _phone,
            isActive: true,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            version: newVersion
        });

        didDocumentHistory[msg.sender].push(updatedDID);

        emit DIDUpdated(msg.sender, _name, newVersion);
    }

    /// @notice 최신 DID 비활성화
    function deactivateLatestDID() external hasActiveDID(msg.sender) {
        uint256 latestIndex = getLatestActiveDIDIndex(msg.sender);
        didDocumentHistory[msg.sender][latestIndex].isActive = false;
        didDocumentHistory[msg.sender][latestIndex].updatedAt = block.timestamp;

        emit DIDDeactivated(
            msg.sender,
            didDocumentHistory[msg.sender][latestIndex].version
        );
    }

    /// @notice 특정 주소의 최신 DID 정보 조회
    /// @param user 조회할 사용자 주소
    /// @return 최신 DID 문서 정보
    function getLatestDID(
        address user
    ) external view returns (DIDDocument memory) {
        uint256 latestIndex = getLatestActiveDIDIndex(user);
        require(
            latestIndex != type(uint256).max,
            unicode"활성화된 DID가 없습니다"
        );
        return didDocumentHistory[user][latestIndex];
    }

    /// @notice 자신의 최신 DID 정보 조회
    /// @return 자신의 최신 DID 문서 정보
    function getMyLatestDID() external view returns (DIDDocument memory) {
        uint256 latestIndex = getLatestActiveDIDIndex(msg.sender);
        require(
            latestIndex != type(uint256).max,
            unicode"활성화된 DID가 없습니다"
        );
        return didDocumentHistory[msg.sender][latestIndex];
    }

    /// @notice 특정 주소의 모든 DID 이력 조회
    /// @param user 조회할 사용자 주소
    /// @return DID 문서 배열
    function getAllDIDHistory(
        address user
    ) external view returns (DIDDocument[] memory) {
        return didDocumentHistory[user];
    }

    /// @notice 자신의 모든 DID 이력 조회
    /// @return 자신의 DID 문서 배열
    function getMyAllDIDHistory() external view returns (DIDDocument[] memory) {
        return didDocumentHistory[msg.sender];
    }

    /// @notice 특정 주소의 활성화된 DID 존재 여부 확인
    /// @param user 확인할 사용자 주소
    /// @return DID 존재 여부
    function hasActiveDIDPublic(address user) external view returns (bool) {
        return getLatestActiveDIDIndex(user) != type(uint256).max;
    }

    /// @notice 특정 주소의 DID 버전 수 조회
    /// @param user 조회할 사용자 주소
    /// @return DID 버전 수
    function getDIDVersionCount(address user) external view returns (uint256) {
        return didDocumentHistory[user].length;
    }

    /// @notice 특정 버전의 DID 조회
    /// @param user 조회할 사용자 주소
    /// @param version 조회할 버전 (1부터 시작)
    /// @return DID 문서 정보
    function getDIDByVersion(
        address user,
        uint256 version
    ) external view returns (DIDDocument memory) {
        require(
            version > 0 && version <= didDocumentHistory[user].length,
            unicode"잘못된 버전 번호입니다"
        );
        return didDocumentHistory[user][version - 1];
    }

    /// @notice 등록된 총 활성 DID 수 조회
    /// @return 활성화된 DID 수
    function getTotalActiveDIDs() external view returns (uint256) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < registeredAddresses.length; i++) {
            if (
                getLatestActiveDIDIndex(registeredAddresses[i]) !=
                type(uint256).max
            ) {
                activeCount++;
            }
        }
        return activeCount;
    }

    /// @notice 등록된 총 주소 수 조회 (DID 이력이 있는 주소)
    /// @return 등록된 주소 수
    function getTotalRegisteredAddresses() external view returns (uint256) {
        return registeredAddresses.length;
    }

    /// @notice 등록된 모든 활성 DID 주소 조회 (관리자만)
    /// @return 활성 DID 주소 배열
    function getAllActiveDIDAddresses()
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
            if (
                getLatestActiveDIDIndex(registeredAddresses[i]) !=
                type(uint256).max
            ) {
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

    /// @notice 등록된 모든 주소 조회 (관리자만)
    /// @return 등록된 모든 주소 배열
    function getAllRegisteredAddresses()
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        return registeredAddresses;
    }

    /// @notice 컨트랙트 소유자 변경 (현재 소유자만)
    /// @param newOwner 새로운 소유자 주소
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), unicode"유효하지 않은 주소입니다");
        owner = newOwner;
    }
}
