# Kaia Contract

Kaia 블록체인에 스마트 컨트랙트를 배포하기 위한 Foundry 기반 프로젝트입니다.

## 특징

- Foundry 기반 스마트 컨트랙트 개발
- Kaia 메인넷/테스트넷 지원
- Bash 스크립트를 통한 자동 배포
- 배포 정보 JSON 자동 저장

## 컨트랙트 목록

### KaiaDID - 탈중앙화 신원 관리 시스템

- **파일**: `src/KaiaDID.sol`
- **기능**: 개인정보(이름, 생년월일, 주소, 전화번호)와 지갑 주소를 매칭하는 DID 컨트랙트
- **주요 기능**:
  - DID 생성 및 업데이트
  - 신원 정보 조회
  - DID 비활성화
  - 관리자 기능 (모든 DID 조회, 소유권 이전)

## 환경 설정

1. 환경 파일 생성:

```bash
cp env.example .env
```

2. `.env` 파일 수정:

```env
PRIVATE_KEY=your_private_key_here
CONTRACT_NAME=KaiaDID
CONSTRUCTOR_ARGS=
GAS_LIMIT=5000000
GAS_PRICE=25000000000
```

## 사용법

### 1. 컨트랙트 컴파일

```bash
forge build
```

### 2. 테스트넷 배포

```bash
./scripts/deploy-testnet.sh
```

### 3. 메인넷 배포

```bash
./scripts/deploy-mainnet.sh
```

### 4. 배포 정보 확인

```bash
cat deployments/testnet-KaiaDID.json
```

## Foundry 기본 사용법

### 빌드

```shell
forge build
```

### 테스트

```shell
forge test
```

### 포맷팅

```shell
forge fmt
```

## 네트워크 정보

### Kaia 메인넷

- Chain ID: 8217
- RPC: https://public-en.node.kaia.io
- Explorer: https://kaiascan.io

### Kaia 테스트넷 (Kairos)

- Chain ID: 1001
- RPC: https://public-en-kairos.node.kaia.io
- Explorer: https://kairos.kaiascan.io
