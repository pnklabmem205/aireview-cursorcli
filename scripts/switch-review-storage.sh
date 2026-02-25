#!/bin/bash

# 리뷰 저장 위치를 전환하는 스크립트
# .git/reviews/ (로컬 전용) <-> reviews/ (공유 가능)

set -e

# 색상 출력
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   리뷰 저장 위치 전환 도구            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# 현재 설정 확인
if grep -q 'REVIEWS_DIR=".git/reviews"' .git/hooks/post-commit 2>/dev/null; then
    CURRENT_MODE="local"
    CURRENT_DIR=".git/reviews"
    NEW_MODE="shared"
    NEW_DIR="reviews"
    echo -e "${YELLOW}현재 설정: 로컬 전용 (.git/reviews/)${NC}"
    echo -e "${YELLOW}→ 변경 후: 공유 가능 (reviews/)${NC}"
elif grep -q 'REVIEWS_DIR="reviews"' .git/hooks/post-commit 2>/dev/null; then
    CURRENT_MODE="shared"
    CURRENT_DIR="reviews"
    NEW_MODE="local"
    NEW_DIR=".git/reviews"
    echo -e "${YELLOW}현재 설정: 공유 가능 (reviews/)${NC}"
    echo -e "${YELLOW}→ 변경 후: 로컬 전용 (.git/reviews/)${NC}"
else
    echo -e "${RED}❌ 리뷰 저장 위치를 확인할 수 없습니다.${NC}"
    exit 1
fi

echo ""
echo "전환 옵션:"
echo "  1) ${NEW_MODE} 모드로 전환 (${NEW_DIR})"
echo "  2) 취소"
read -p "선택 (1-2, 기본값: 2): " CHOICE
CHOICE=${CHOICE:-2}

if [ "$CHOICE" != "1" ]; then
    echo -e "${YELLOW}취소되었습니다.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}리뷰 저장 위치를 전환하는 중...${NC}"

# Hook 파일들 수정
HOOK_FILES=".git/hooks/post-commit .git/hooks/pre-commit .git/hooks/pre-push"

for hook_file in $HOOK_FILES; do
    if [ -f "$hook_file" ]; then
        # REVIEWS_DIR 변수 변경
        sed -i "s|REVIEWS_DIR=\"$CURRENT_DIR\"|REVIEWS_DIR=\"$NEW_DIR\"|g" "$hook_file"
        # REVIEWS_TEMP_DIR도 변경 (pre-commit에서 사용)
        sed -i "s|REVIEWS_TEMP_DIR=\"$CURRENT_DIR-temp\"|REVIEWS_TEMP_DIR=\"$NEW_DIR-temp\"|g" "$hook_file" 2>/dev/null || true
        # Git notes 메시지도 변경
        sed -i "s|$CURRENT_DIR|$NEW_DIR|g" "$hook_file"
        echo -e "${GREEN}✓ $hook_file 수정 완료${NC}"
    fi
done

# 기존 리뷰 파일 이동
if [ -d "$CURRENT_DIR" ] && [ "$(ls -A $CURRENT_DIR 2>/dev/null)" ]; then
    echo ""
    echo -e "${YELLOW}기존 리뷰 파일을 이동하시겠습니까? (Y/n)${NC}"
    read -t 10 -n 1 MOVE_FILES || MOVE_FILES="y"
    
    if [ "$MOVE_FILES" != "n" ] && [ "$MOVE_FILES" != "N" ]; then
        mkdir -p "$NEW_DIR"
        cp -r "$CURRENT_DIR"/* "$NEW_DIR/" 2>/dev/null || true
        echo -e "${GREEN}✓ 리뷰 파일 이동 완료${NC}"
        
        if [ "$NEW_MODE" = "shared" ]; then
            echo ""
            echo -e "${YELLOW}리뷰 디렉토리를 Git에 추가하시겠습니까? (Y/n)${NC}"
            read -t 10 -n 1 ADD_TO_GIT || ADD_TO_GIT="y"
            
            if [ "$ADD_TO_GIT" != "n" ] && [ "$ADD_TO_GIT" != "N" ]; then
                git add "$NEW_DIR/" 2>/dev/null || true
                echo -e "${GREEN}✓ Git에 추가 완료${NC}"
                echo -e "${YELLOW}  (다음 커밋에 포함됩니다)${NC}"
            fi
        fi
    fi
fi

# view-review.sh 스크립트도 업데이트
if [ -f "scripts/view-review.sh" ]; then
    sed -i "s|REVIEWS_DIR=\"$CURRENT_DIR\"|REVIEWS_DIR=\"$NEW_DIR\"|g" "scripts/view-review.sh"
    echo -e "${GREEN}✓ scripts/view-review.sh 수정 완료${NC}"
fi

echo ""
echo -e "${GREEN}✅ 리뷰 저장 위치 전환 완료!${NC}"
echo ""
if [ "$NEW_MODE" = "shared" ]; then
    echo -e "${BLUE}이제 리뷰가 'reviews/' 디렉토리에 저장되며,${NC}"
    echo -e "${BLUE}Git에 포함되어 다른 사람과 공유할 수 있습니다.${NC}"
else
    echo -e "${BLUE}이제 리뷰가 '.git/reviews/' 디렉토리에 저장되며,${NC}"
    echo -e "${BLUE}로컬에만 저장되어 push되지 않습니다.${NC}"
fi
