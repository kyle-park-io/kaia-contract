#!/bin/bash

# ABI 추출 스크립트 - KaiaDID3 전용

echo "🔍 KaiaDID3 ABI 추출 시작..."

# 타임스탬프 생성
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

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

# KaiaDID3 컨트랙트 ABI 추출
echo "📄 KaiaDID3 ABI 추출 중..."

# JSON에서 ABI만 추출 (타임스탬프 포함)
ABI_FILE="abi/KaiaDID3_${TIMESTAMP}.json"
jq '.abi' out/KaiaDID3.sol/KaiaDID3.json >"$ABI_FILE"

if [ $? -eq 0 ]; then
    echo "✅ KaiaDID3 ABI 추출 완료: $ABI_FILE"

    # 최신 버전으로 파일 복사 (호환성을 위해)
    cp "$ABI_FILE" "abi/KaiaDID3_latest.json"
    echo "📄 최신 ABI 파일 생성: abi/KaiaDID3_latest.json"
else
    echo "❌ KaiaDID3 ABI 추출 실패"
    exit 1
fi

# 다른 KaiaDID 컨트랙트들도 추가로 추출
for contract_dir in out/*/; do
    if [ -d "$contract_dir" ]; then
        contract_name=$(basename "$contract_dir" .sol)

        # Foundry 시스템 컨트랙트나 라이브러리는 제외
        if [[ "$contract_name" =~ ^(Base|console|console2|Counter|Test|Std|Vm|Script|IMulticall3|safeconsole) ]]; then
            continue
        fi

        # KaiaDID 관련 컨트랙트만 처리
        if [[ "$contract_name" =~ ^KaiaDID[0-9]*$ ]]; then
            json_file="$contract_dir$contract_name.json"
            if [ -f "$json_file" ]; then
                echo "📄 $contract_name ABI 추출 중..."
                contract_abi_file="abi/${contract_name}_${TIMESTAMP}.json"
                jq '.abi' "$json_file" >"$contract_abi_file"
                if [ $? -eq 0 ]; then
                    echo "✅ $contract_name ABI 추출 완료: $contract_abi_file"
                    # 최신 버전 파일 복사
                    cp "$contract_abi_file" "abi/${contract_name}_latest.json"
                else
                    echo "⚠️  $contract_name ABI 추출 실패"
                fi
            fi
        fi
    fi
done

# TypeScript 타입 정의 생성 (선택사항)
if command -v typechain &>/dev/null; then
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
