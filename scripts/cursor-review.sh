#!/bin/bash

# Cursor CLI Agent를 사용한 수동 코드 리뷰 스크립트
# git push 전에 수동으로 리뷰를 실행할 수 있습니다

set -e

# 색상 출력
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_spinner() {
    local pid="$1"
    local delay=0.1
    local spin="|/-\\"
    local i=0

    # stderr로만 출력해서 실제 리뷰 결과(stdout)와 섞이지 않게 함
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\r${YELLOW}🤖 Cursor AI Agent가 코드를 리뷰 중입니다... %s${NC}" "${spin:$i:1}" 1>&2
        sleep "$delay"
    done
    printf "\r${YELLOW}🤖 Cursor AI Agent 리뷰가 완료되었습니다.     ${NC}\n" 1>&2
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Cursor AI 수동 코드 리뷰            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# 변경사항 확인 옵션
echo "리뷰할 변경사항을 선택하세요:"
echo "  1) 스테이징된 변경사항 (git diff --cached)"
echo "  2) 마지막 커밋 (HEAD)"
echo "  3) 특정 커밋 범위"
echo "  4) 원격 브랜치와 비교"
read -p "선택 (1-4, 기본값: 1): " CHOICE
CHOICE=${CHOICE:-1}

case $CHOICE in
    1)
        CHANGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")
        DIFF_CONTENT=$(git diff --cached 2>/dev/null || echo "")
        COMPARE_TYPE="스테이징된 변경사항"
        ;;
    2)
        CHANGED_FILES=$(git diff HEAD~1..HEAD --name-only 2>/dev/null || echo "")
        DIFF_CONTENT=$(git diff HEAD~1..HEAD 2>/dev/null || echo "")
        COMPARE_TYPE="마지막 커밋"
        ;;
    3)
        read -p "시작 커밋: " START_COMMIT
        read -p "끝 커밋 (기본값: HEAD): " END_COMMIT
        END_COMMIT=${END_COMMIT:-HEAD}
        CHANGED_FILES=$(git diff --name-only $START_COMMIT..$END_COMMIT 2>/dev/null || echo "")
        DIFF_CONTENT=$(git diff $START_COMMIT..$END_COMMIT 2>/dev/null || echo "")
        COMPARE_TYPE="$START_COMMIT..$END_COMMIT"
        ;;
    4)
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        read -p "원격 브랜치 (기본값: origin/$CURRENT_BRANCH): " REMOTE_BRANCH
        REMOTE_BRANCH=${REMOTE_BRANCH:-origin/$CURRENT_BRANCH}
        CHANGED_FILES=$(git diff --name-only $REMOTE_BRANCH..HEAD 2>/dev/null || echo "")
        DIFF_CONTENT=$(git diff $REMOTE_BRANCH..HEAD 2>/dev/null || echo "")
        COMPARE_TYPE="$REMOTE_BRANCH..HEAD"
        ;;
    *)
        echo -e "${RED}잘못된 선택입니다.${NC}"
        exit 1
        ;;
esac

if [ -z "$CHANGED_FILES" ]; then
    echo -e "${YELLOW}⚠️  변경된 파일이 없습니다.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}📝 리뷰 대상: $COMPARE_TYPE${NC}"

FILE_COUNT=$(echo "$CHANGED_FILES" | sed '/^\s*$/d' | wc -l | tr -d ' ')
DIFF_LINES=$(echo "$DIFF_CONTENT" | wc -l | tr -d ' ')
echo -e "${YELLOW}📝 변경된 파일 수:${NC} $FILE_COUNT개"
echo -e "${YELLOW}📝 diff 라인 수:${NC} $DIFF_LINES줄"
echo -e "${YELLOW}📝 변경된 파일 목록:${NC}"
echo "$CHANGED_FILES" | sed 's/^/  • /'
echo ""

# 임시 파일에 diff 저장
TEMP_DIFF=$(mktemp)
echo "$DIFF_CONTENT" > "$TEMP_DIFF"

# 리뷰 프롬프트
REVIEW_PROMPT="다음 Git 변경사항을 코드 리뷰해주세요.

리뷰 대상: $COMPARE_TYPE
변경된 파일:
$(echo "$CHANGED_FILES" | sed 's/^/- /')

변경사항 (diff):
\`\`\`
$(cat "$TEMP_DIFF")
\`\`\`

리뷰 기준:
1. 버그나 잠재적 오류 확인
2. 코드 품질과 가독성 평가
3. 보안 취약점 확인
4. 성능 문제 확인
5. 베스트 프랙티스 준수 여부
6. 테스트 가능성 고려

리뷰 결과를 다음 형식으로 반환해주세요:

## 리뷰 결과

**상태**: [PASS/FAIL/WARNING]
**요약**: [한 줄 요약]

**발견된 이슈**:
- [이슈 1]
- [이슈 2]

**개선 제안**:
- [제안 1]
- [제안 2]"

echo -e "${YELLOW}🤖 Cursor AI Agent가 코드를 리뷰 중입니다... (진행 상황을 표시합니다)${NC}"
echo ""

# Cursor CLI Agent로 리뷰 실행 (리뷰 진행 중 스피너 표시)
TEMP_REVIEW_OUTPUT=$(mktemp)
set +e
cursor agent --print --output-format text --workspace "$PROJECT_ROOT" --trust "$REVIEW_PROMPT" >"$TEMP_REVIEW_OUTPUT" 2>&1 &
CURSOR_PID=$!
set -e

show_spinner "$CURSOR_PID"

set +e
wait "$CURSOR_PID"
REVIEW_EXIT_CODE=$?
set -e

REVIEW_OUTPUT=$(cat "$TEMP_REVIEW_OUTPUT")
rm -f "$TEMP_REVIEW_OUTPUT"

# 임시 파일 삭제
rm -f "$TEMP_DIFF"

if [ $REVIEW_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}❌ AI 리뷰 실행 중 오류가 발생했습니다.${NC}"
    echo "$REVIEW_OUTPUT"
    exit 1
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         AI 리뷰 결과                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo "$REVIEW_OUTPUT"
echo ""
