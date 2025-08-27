# Kaia DID 프로젝트

**Kaia 스테이블 코인 해커톤** 출품작 - 탈중앙화 신원 관리 시스템

개인정보와 지갑 주소를 매칭하는 DID(Decentralized Identity) 컨트랙트로, 블록체인 기반의 신원 인증 시스템을 제공합니다.

## 🎯 프로젝트 개요

실생활에서 사용할 수 있는 탈중앙화 신원 증명 시스템을 구축하여, 개인의 신원 정보를 블록체인에 안전하게 저장하고 관리할 수 있도록 합니다.

## 🚀 특징

- Foundry 기반 스마트 컨트랙트 개발
- Kaia 메인넷/테스트넷 지원
- 단계별 구현으로 점진적 기능 개선
- 완전한 테스트 커버리지
- 자동 배포 및 ABI 추출

## 📋 컨트랙트 버전별 구현 내용

### 🔹 KaiaDID (v1) - 기본 DID 시스템

- **파일**: `src/KaiaDID.sol`
- **설명**: 기본적인 DID 생성, 조회, 업데이트, 비활성화 기능
- **주요 기능**:
  - 개인정보 등록 (이름, 생년월일, 주소, 전화번호)
  - DID 정보 조회 및 업데이트
  - DID 비활성화
  - 관리자 권한 관리

### ⏰ KaiaDID2 (v2) - 유효시간 추가

- **파일**: `src/KaiaDID2.sol`
- **설명**: v1에 DID 유효시간 관리 기능 추가
- **추가 기능**:
  - **5분 유효시간**: DID는 생성 후 5분간만 유효
  - **DID 갱신**: 만료 전 유효시간 연장 가능
  - **만료 확인**: DID 만료 여부 및 남은 시간 조회
  - **자동 만료**: 만료된 DID는 자동으로 조회 불가

### 🎭 KaiaDID3 (v3) - 시연용 중복 처리 제거

- **파일**: `src/KaiaDID3.sol`
- **설명**: 시연의 편의성을 위해 중복 처리 제거 및 버전 관리 추가
- **개선 사항**:
  - **다중 DID 생성**: 한 주소에서 여러 DID 생성 가능
  - **버전 관리**: 각 DID마다 버전 번호 부여
  - **이력 관리**: 모든 DID 생성/수정 이력 보존
  - **유연한 업데이트**: 새로운 DID 생성으로 정보 업데이트

## ⚙️ 환경 설정

### 1. 의존성 설치

```bash
# Foundry 설치 (필요한 경우)
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. 환경 파일 생성

```bash
cp env.example .env
```

### 3. `.env` 파일 수정

```env
PRIVATE_KEY=your_private_key_here
CONTRACT_NAME=KaiaDID3  # 배포할 컨트랙트 선택
CONSTRUCTOR_ARGS=
GAS_LIMIT=5000000
GAS_PRICE=25000000000
```

## 🛠️ 개발 및 테스트

### 컨트랙트 컴파일

```bash
forge build
```

### 전체 테스트 실행

```bash
forge test
```

### 특정 컨트랙트 테스트

```bash
# KaiaDID v1 테스트
forge test --match-contract KaiaDIDTest

# KaiaDID v2 테스트
forge test --match-contract KaiaDID2Test

# KaiaDID v3 테스트
forge test --match-contract KaiaDID3Test
```

### 상세 테스트 결과 확인

```bash
forge test -vvv
```

### 테스트 커버리지 확인

```bash
forge coverage
```

## 🚀 배포 가이드

### 테스트넷 배포 (Kairos)

```bash
# 특정 버전 배포하려면 .env에서 CONTRACT_NAME 수정 후
./scripts/deploy-testnet.sh
```

### 메인넷 배포

```bash
./scripts/deploy-mainnet.sh
```

### 수동 배포 (Forge 명령어)

```bash
# KaiaDID v1 배포
forge script script/KaiaDID.s.sol --rpc-url https://public-en-kairos.node.kaia.io --broadcast --verify

# KaiaDID v2 배포
forge script script/KaiaDID2.s.sol --rpc-url https://public-en-kairos.node.kaia.io --broadcast --verify

# KaiaDID v3 배포
forge script script/KaiaDID3.s.sol --rpc-url https://public-en-kairos.node.kaia.io --broadcast --verify
```

## 📁 ABI 및 배포 정보

### ABI 추출

배포 시 자동으로 ABI가 추출되지만, 별도로 추출하려면:

```bash
./scripts/extract-abi.sh
```

### 배포 정보 확인

```bash
# 최신 배포 정보
cat deployments/testnet-KaiaDID3_latest.json

# 특정 시간 배포 정보
ls deployments/
```

배포 정보에는 다음이 포함됩니다:

- 컨트랙트 주소
- 트랜잭션 해시
- 배포 시간
- ABI 파일 경로
- 네트워크 정보

## 🔧 유용한 Foundry 명령어

### 코드 포맷팅

```bash
forge fmt
```

### 컨트랙트 사이즈 확인

```bash
forge build --sizes
```

### Gas 사용량 분석

```bash
forge test --gas-report
```

### 컨트랙트 정보 확인

```bash
forge inspect src/KaiaDID3.sol:KaiaDID3 abi
```

## 🌐 네트워크 정보

### Kaia 테스트넷 (Kairos) - 개발용

- **Chain ID**: 1001
- **RPC**: https://public-en-kairos.node.kaia.io
- **Explorer**: https://kairos.kaiascan.io
- **Faucet**: https://kairos.wallet.kaia.io/faucet

### Kaia 메인넷 - 프로덕션용

- **Chain ID**: 8217
- **RPC**: https://public-en.node.kaia.io
- **Explorer**: https://kaiascan.io

## 📊 현재 배포 상태

### 테스트넷 (Kairos) 배포 컨트랙트

```bash
# 최신 배포된 KaiaDID3 컨트랙트 주소 확인
cat deployments/testnet-KaiaDID3_latest.json
```

## 🤝 해커톤 팀 정보

**Kaia 스테이블 코인 해커톤** 참여 프로젝트

- **프로젝트명**: Kaia DID - 탈중앙화 신원 관리 시스템
- **목표**: 실용적인 블록체인 기반 신원 인증 시스템 구축
- **기술 스택**: Solidity, Foundry, Kaia Blockchain

## 📝 라이선스

MIT License

---

## 🚀 빠른 시작 가이드

1. **저장소 클론**

   ```bash
   git clone <repository-url>
   cd kaia-contract
   ```

2. **환경 설정**

   ```bash
   cp env.example .env
   # .env 파일에 PRIVATE_KEY 입력
   ```

3. **컴파일 및 테스트**

   ```bash
   forge build
   forge test
   ```

4. **테스트넷 배포**

   ```bash
   ./scripts/deploy-testnet.sh
   ```

5. **배포 확인**
   ```bash
   cat deployments/testnet-KaiaDID3_latest.json
   ```
