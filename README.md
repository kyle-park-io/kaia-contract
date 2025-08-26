# Kaia Blockchain 스마트 컨트랙트 프로젝트

Foundry를 사용한 Kaia 블록체인 개발 환경

## 프로젝트 구조

```
├── src/           # 스마트 컨트랙트 소스 코드
├── test/          # 테스트 파일
├── script/        # 배포 스크립트
├── lib/           # 외부 라이브러리
└── foundry.toml   # Foundry 설정 파일
```

## 설치 및 설정

1. Foundry 설치 (이미 완료됨)

```shell
brew install foundry
```

2. 의존성 설치

```shell
forge install
```

## 사용법

### 빌드

```shell
forge build
```

### 테스트

```shell
forge test
```

### 가스 스냅샷

```shell
forge snapshot
```

### 로컬 노드 실행

```shell
anvil
```

### Kaia 테스트넷 배포

```shell
forge script script/Counter.s.sol:CounterScript \
  --rpc-url kaia-testnet \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### Kaia 메인넷 배포

```shell
forge script script/Counter.s.sol:CounterScript \
  --rpc-url kaia-mainnet \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## Kaia 블록체인 정보

- **메인넷 RPC**: https://public-en-cypress.klaytn.net
- **테스트넷 RPC**: https://public-en-baobab.klaytn.net
- **EVM 호환**: 완전 호환
- **솔리디티 지원**: 모든 버전 지원

## 환경 변수 설정

`.env.example`을 참고하여 `.env` 파일 생성:

```env
KAIA_MAINNET_RPC_URL=https://public-en-cypress.klaytn.net
KAIA_TESTNET_RPC_URL=https://public-en-baobab.klaytn.net
PRIVATE_KEY=your_private_key_here
```

## 도움말

```shell
forge --help
anvil --help
cast --help
```
