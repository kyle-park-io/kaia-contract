#!/bin/bash

# Kaia 테스트넷 배포 스크립트

echo "🚀 Kaia 테스트넷 배포 시작..."

# .env 파일 확인
if [ ! -f .env ]; then
    echo "❌ .env 파일이 없습니다. env.example을 복사해서 .env를 만드세요."
    exit 1
fi

# .env 파일 로드
source .env

# 필수 환경변수 확인
if [ -z "$PRIVATE_KEY" ]; then
    echo "❌ PRIVATE_KEY가 설정되지 않았습니다."
    exit 1
fi

if [ -z "$KAIA_TESTNET_RPC" ]; then
    echo "❌ KAIA_TESTNET_RPC가 설정되지 않았습니다."
    exit 1
fi

if [ -z "$CONTRACT_NAME" ]; then
    echo "❌ CONTRACT_NAME이 설정되지 않았습니다."
    exit 1
fi

echo "📋 배포 정보:"
echo "  네트워크: Kaia Testnet"
echo "  RPC: $KAIA_TESTNET_RPC"
echo "  컨트랙트: $CONTRACT_NAME"
echo "  가스 한도: $GAS_LIMIT"
echo "  가스 가격: $GAS_PRICE"

# deployments 및 abi 디렉토리 생성
mkdir -p deployments
mkdir -p abi

# 컨트랙트 컴파일
echo "🔨 컨트랙트 컴파일 중..."
forge build

if [ $? -ne 0 ]; then
    echo "❌ 컴파일 실패"
    exit 1
fi

echo "✅ 컴파일 완료"

# ABI 추출
echo "📄 ABI 추출 중..."
jq '.abi' out/${CONTRACT_NAME}.sol/${CONTRACT_NAME}.json > abi/${CONTRACT_NAME}.json

if [ $? -eq 0 ]; then
    echo "✅ ${CONTRACT_NAME} ABI 추출 완료: abi/${CONTRACT_NAME}.json"
else
    echo "⚠️  ABI 추출 실패, 배포는 계속 진행합니다."
fi

# 배포 실행
echo "🚀 배포 중..."
echo "실행 명령어: forge script script/${CONTRACT_NAME}.s.sol:${CONTRACT_NAME}Script --rpc-url $KAIA_TESTNET_RPC --broadcast"

DEPLOY_OUTPUT=$(forge script script/${CONTRACT_NAME}.s.sol:${CONTRACT_NAME}Script \
    --rpc-url $KAIA_TESTNET_RPC \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --gas-limit $GAS_LIMIT \
    --gas-price $GAS_PRICE \
    -vvv 2>&1)

echo "=== 배포 출력 ==="
echo "$DEPLOY_OUTPUT"
echo "================="

# 배포 결과 확인
if [ $? -eq 0 ]; then
    echo "✅ 배포 성공!"
    
    # 배포 정보 추출 및 JSON 저장
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # 컨트랙트 주소 추출 (로그에서)
    CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -o "주소: 0x[a-fA-F0-9]*" | cut -d' ' -f2)
    
    # broadcast 폴더에서 실제 배포 정보 읽기
    BROADCAST_FILE="broadcast/${CONTRACT_NAME}.s.sol/1001/run-latest.json"
    if [ -f "$BROADCAST_FILE" ]; then
        TX_HASH=$(jq -r '.transactions[0].hash' "$BROADCAST_FILE" 2>/dev/null || echo "")
        BLOCK_NUMBER=$(jq -r '.receipts[0].blockNumber' "$BROADCAST_FILE" 2>/dev/null || echo "")
    else
        TX_HASH=""
        BLOCK_NUMBER=""
    fi
    
    # JSON 파일 생성
    cat > "deployments/testnet-${CONTRACT_NAME}.json" << EOF
{
  "network": "testnet",
  "chainId": 1001,
  "contract": "$CONTRACT_NAME",
  "address": "$CONTRACT_ADDRESS",
  "deploymentTx": "$TX_HASH",
  "blockNumber": "$BLOCK_NUMBER",
  "timestamp": "$TIMESTAMP",
  "abi": "abi/${CONTRACT_NAME}.json",
  "deployer": {
    "gasLimit": "$GAS_LIMIT",
    "gasPrice": "$GAS_PRICE"
  },
  "explorer": {
    "contractUrl": "https://kairos.kaiascan.io/account/$CONTRACT_ADDRESS",
    "txUrl": "https://kairos.kaiascan.io/tx/$TX_HASH"
  }
}
EOF
    
    echo ""
    echo "📄 배포 정보:"
    echo "  컨트랙트 주소: $CONTRACT_ADDRESS"
    echo "  트랜잭션 해시: $TX_HASH"
    echo "  블록 번호: $BLOCK_NUMBER"
    echo "  ABI 파일: abi/${CONTRACT_NAME}.json"
    echo "  탐색기: https://kairos.kaiascan.io/account/$CONTRACT_ADDRESS"
    echo ""
    echo "💾 배포 정보가 저장되었습니다: deployments/testnet-${CONTRACT_NAME}.json"
    echo "📄 ABI 파일이 준비되었습니다: abi/${CONTRACT_NAME}.json"
    
else
    echo "❌ 배포 실패"
    echo "$DEPLOY_OUTPUT"
    exit 1
fi
