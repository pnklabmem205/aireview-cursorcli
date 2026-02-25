#!/bin/bash

# 저장된 리뷰 결과를 조회하는 스크립트

set -e

# 색상 출력
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REVIEWS_DIR="reviews"

if [ ! -d "$REVIEWS_DIR" ]; then
    echo -e "${YELLOW}⚠️  리뷰 디렉토리가 없습니다.${NC}"
    exit 0
fi

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      저장된 리뷰 결과 조회            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# 리뷰 조회 옵션
echo "리뷰를 조회할 방법을 선택하세요:"
echo "  1) 최근 커밋의 리뷰"
echo "  2) 특정 커밋 해시의 리뷰"
echo "  3) 모든 리뷰 목록"
echo "  4) 특정 파일 검색"
read -p "선택 (1-4, 기본값: 1): " CHOICE
CHOICE=${CHOICE:-1}

case $CHOICE in
    1)
        # 최근 커밋의 리뷰
        COMMIT_HASH=$(git rev-parse HEAD)
        REVIEW_FILE="$REVIEWS_DIR/${COMMIT_HASH}.md"
        if [ -f "$REVIEW_FILE" ]; then
            echo -e "${GREEN}📝 커밋: $COMMIT_HASH${NC}"
            echo ""
            cat "$REVIEW_FILE"
        else
            echo -e "${YELLOW}⚠️  이 커밋에 대한 리뷰가 없습니다.${NC}"
            echo -e "${YELLOW}   (Pre-commit hook이 실행되지 않았거나 리뷰가 저장되지 않았습니다)${NC}"
        fi
        ;;
    2)
        # 특정 커밋 해시의 리뷰
        read -p "커밋 해시 (전체 또는 일부): " COMMIT_HASH
        if [ -z "$COMMIT_HASH" ]; then
            echo -e "${RED}커밋 해시를 입력해주세요.${NC}"
            exit 1
        fi
        
        # 짧은 해시인 경우 전체 해시로 변환
        FULL_HASH=$(git rev-parse "$COMMIT_HASH" 2>/dev/null || echo "$COMMIT_HASH")
        REVIEW_FILE="$REVIEWS_DIR/${FULL_HASH}.md"
        
        if [ -f "$REVIEW_FILE" ]; then
            echo -e "${GREEN}📝 커밋: $FULL_HASH${NC}"
            echo ""
            cat "$REVIEW_FILE"
        else
            echo -e "${YELLOW}⚠️  이 커밋에 대한 리뷰가 없습니다.${NC}"
        fi
        ;;
    3)
        # 모든 리뷰 목록
        echo -e "${BLUE}📋 저장된 리뷰 목록:${NC}"
        echo ""
        
        REVIEW_COUNT=0
        for review_file in "$REVIEWS_DIR"/*.md; do
            if [ -f "$review_file" ]; then
                REVIEW_COUNT=$((REVIEW_COUNT + 1))
                filename=$(basename "$review_file")
                if [[ "$filename" =~ ^([a-f0-9]{40})\.md$ ]]; then
                    # 커밋 해시인 경우
                    commit_hash="${BASH_REMATCH[1]}"
                    commit_msg=$(git log --oneline -1 "$commit_hash" 2>/dev/null || echo "알 수 없는 커밋")
                    echo -e "  ${GREEN}$commit_hash${NC} - $commit_msg"
                else
                    # Push 리뷰인 경우
                    echo -e "  ${YELLOW}$filename${NC}"
                fi
            fi
        done
        
        if [ $REVIEW_COUNT -eq 0 ]; then
            echo -e "${YELLOW}  저장된 리뷰가 없습니다.${NC}"
        else
            echo ""
            echo -e "${BLUE}총 $REVIEW_COUNT개의 리뷰가 저장되어 있습니다.${NC}"
        fi
        ;;
    4)
        # 특정 파일 검색
        read -p "검색할 파일명 (부분 일치 가능): " SEARCH_FILE
        if [ -z "$SEARCH_FILE" ]; then
            echo -e "${RED}파일명을 입력해주세요.${NC}"
            exit 1
        fi
        
        echo -e "${BLUE}🔍 '$SEARCH_FILE'를 포함한 리뷰 검색:${NC}"
        echo ""
        
        FOUND=0
        for review_file in "$REVIEWS_DIR"/*.md; do
            if [ -f "$review_file" ] && grep -qi "$SEARCH_FILE" "$review_file"; then
                FOUND=1
                filename=$(basename "$review_file")
                echo -e "${GREEN}📄 $filename${NC}"
                echo "---"
                grep -i "$SEARCH_FILE" "$review_file" | head -5
                echo ""
            fi
        done
        
        if [ $FOUND -eq 0 ]; then
            echo -e "${YELLOW}  '$SEARCH_FILE'를 포함한 리뷰를 찾을 수 없습니다.${NC}"
        fi
        ;;
    *)
        echo -e "${RED}잘못된 선택입니다.${NC}"
        exit 1
        ;;
esac
