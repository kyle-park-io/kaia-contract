#!/bin/bash

# ABI 추출 스크립트

echo "🔍 ABI 추출 시작..."

# abi 디렉토리 생성
mkdir -p abi

# 컨트랙트 빌드
echo "🔨 컨트랙트 빌드 중..."
forge build

if [ $? -ne 0 ]; then
    echo "❌ 빌드 실패"
    exit 1
fi

echo "✅ 빌드 완료"

# KaiaDID 컨트랙트 ABI 추출
echo "📄 KaiaDID ABI 추출 중..."

# JSON에서 ABI만 추출
jq '.abi' out/KaiaDID.sol/KaiaDID.json > abi/KaiaDID.json

if [ $? -eq 0 ]; then
    echo "✅ KaiaDID ABI 추출 완료: abi/KaiaDID.json"
else
    echo "❌ KaiaDID ABI 추출 실패"
    exit 1
fi

# 다른 프로젝트 컨트랙트들도 추가로 추출
for contract_dir in out/*/; do
    if [ -d "$contract_dir" ]; then
        contract_name=$(basename "$contract_dir" .sol)
        
        # Foundry 시스템 컨트랙트나 라이브러리는 제외
        if [[ "$contract_name" =~ ^(Base|console|console2|Counter|Test|Std|Vm|Script|IMulticall3|safeconsole) ]]; then
            continue
        fi
        
        # KaiaDID는 이미 처리했으므로 제외
        if [[ "$contract_name" == "KaiaDID" ]]; then
            continue
        fi
        
        json_file="$contract_dir$contract_name.json"
        if [ -f "$json_file" ]; then
            echo "📄 $contract_name ABI 추출 중..."
            jq '.abi' "$json_file" > "abi/$contract_name.json"
            if [ $? -eq 0 ]; then
                echo "✅ $contract_name ABI 추출 완료: abi/$contract_name.json"
            else
                echo "⚠️  $contract_name ABI 추출 실패"
            fi
        fi
    fi
done

# TypeScript 타입 정의 생성 (선택사항)
if command -v typechain &> /dev/null; then
    echo "🔄 TypeScript 타입 정의 생성 중..."
    mkdir -p types
    typechain --target ethers-v6 --out-dir types 'abi/*.json'
    if [ $? -eq 0 ]; then
        echo "✅ TypeScript 타입 정의 생성 완료: types/"
    else
        echo "⚠️  TypeScript 타입 정의 생성 실패"
    fi
else
    echo "💡 typechain이 설치되어 있지 않습니다. TypeScript 타입 정의를 생성하려면 설치하세요:"
    echo "   npm install -g typechain @typechain/ethers-v6"
fi

echo ""
echo "📦 추출된 ABI 파일들:"
ls -la abi/

echo ""
echo "✅ ABI 추출 완료!"
echo "💡 프런트엔드에서 사용할 수 있도록 abi/ 디렉토리의 JSON 파일들을 복사하세요."
