#!/bin/bash

# Kaia 메인넷 배포 스크립트

echo "🚀 Kaia 메인넷 배포 시작..."
echo "⚠️  메인넷 배포는 실제 KAIA를 소모합니다!"

# 사용자 확인
read -p "메인넷에 배포하시겠습니까? (yes/no): " answer
if [ "$answer" != "yes" ] && [ "$answer" != "y" ]; then
    echo "배포가 취소되었습니다."
    exit 0
fi

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

if [ -z "$KAIA_MAINNET_RPC" ]; then
    echo "❌ KAIA_MAINNET_RPC가 설정되지 않았습니다."
    exit 1
fi

if [ -z "$CONTRACT_NAME" ]; then
    echo "❌ CONTRACT_NAME이 설정되지 않았습니다."
    exit 1
fi

echo "📋 배포 정보:"
echo "  네트워크: Kaia Mainnet"
echo "  RPC: $KAIA_MAINNET_RPC"
echo "  컨트랙트: $CONTRACT_NAME"
echo "  가스 한도: $GAS_LIMIT"
echo "  가스 가격: $GAS_PRICE"

# deployments 디렉토리 생성
mkdir -p deployments

# 컨트랙트 컴파일
echo "🔨 컨트랙트 컴파일 중..."
forge build

if [ $? -ne 0 ]; then
    echo "❌ 컴파일 실패"
    exit 1
fi

echo "✅ 컴파일 완료"

# 배포 실행
echo "🚀 배포 중..."
echo "실행 명령어: forge script script/${CONTRACT_NAME}.s.sol:${CONTRACT_NAME}Script --rpc-url $KAIA_MAINNET_RPC --broadcast"

DEPLOY_OUTPUT=$(forge script script/${CONTRACT_NAME}.s.sol:${CONTRACT_NAME}Script \
    --rpc-url $KAIA_MAINNET_RPC \
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
    BROADCAST_FILE="broadcast/${CONTRACT_NAME}.s.sol/8217/run-latest.json"
    if [ -f "$BROADCAST_FILE" ]; then
        TX_HASH=$(jq -r '.transactions[0].hash' "$BROADCAST_FILE" 2>/dev/null || echo "")
        BLOCK_NUMBER=$(jq -r '.receipts[0].blockNumber' "$BROADCAST_FILE" 2>/dev/null || echo "")
    else
        TX_HASH=""
        BLOCK_NUMBER=""
    fi
    
    # JSON 파일 생성
    cat > "deployments/mainnet-${CONTRACT_NAME}.json" << EOF
{
  "network": "mainnet",
  "chainId": 8217,
  "contract": "$CONTRACT_NAME",
  "address": "$CONTRACT_ADDRESS",
  "deploymentTx": "$TX_HASH",
  "blockNumber": "$BLOCK_NUMBER",
  "timestamp": "$TIMESTAMP",
  "deployer": {
    "gasLimit": "$GAS_LIMIT",
    "gasPrice": "$GAS_PRICE"
  },
  "explorer": {
    "contractUrl": "https://kaiascan.io/account/$CONTRACT_ADDRESS",
    "txUrl": "https://kaiascan.io/tx/$TX_HASH"
  }
}
EOF
    
    echo ""
    echo "📄 배포 정보:"
    echo "  컨트랙트 주소: $CONTRACT_ADDRESS"
    echo "  트랜잭션 해시: $TX_HASH"
    echo "  블록 번호: $BLOCK_NUMBER"
    echo "  탐색기: https://kaiascan.io/account/$CONTRACT_ADDRESS"
    echo ""
    echo "⚠️  컨트랙트 주소를 안전한 곳에 보관하세요!"
    echo "💾 배포 정보가 저장되었습니다: deployments/mainnet-${CONTRACT_NAME}.json"
    
else
    echo "❌ 배포 실패"
    echo "$DEPLOY_OUTPUT"
    exit 1
fi
