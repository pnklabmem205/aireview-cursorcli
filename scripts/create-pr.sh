#!/bin/bash

# PR 생성 스크립트
# 현재 브랜치를 origin에 push하고 PR을 생성합니다

set -e

# 색상 출력
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Pull Request 생성 도구              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# 현재 브랜치 확인
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ] || [ "$CURRENT_BRANCH" = "master" ] || [ "$CURRENT_BRANCH" = "main" ]; then
    echo -e "${RED}❌ 기본 브랜치($CURRENT_BRANCH)에서는 PR을 생성할 수 없습니다.${NC}"
    echo -e "${YELLOW}   다른 브랜치를 생성해주세요:${NC}"
    echo -e "${YELLOW}   git checkout -b feature/your-feature${NC}"
    exit 1
fi

# 원격 저장소 확인
REMOTE=$(git remote | head -1 || echo "origin")
REMOTE_URL=$(git remote get-url "$REMOTE" 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
    echo -e "${RED}❌ 원격 저장소가 설정되어 있지 않습니다.${NC}"
    echo -e "${YELLOW}   원격 저장소를 추가해주세요:${NC}"
    echo -e "${YELLOW}   git remote add origin <repository-url>${NC}"
    exit 1
fi

echo -e "${GREEN}현재 브랜치: $CURRENT_BRANCH${NC}"
echo -e "${GREEN}원격 저장소: $REMOTE${NC}"
echo ""

# 커밋 확인
COMMITS_AHEAD=$(git rev-list --count "$REMOTE/$DEFAULT_BRANCH"..HEAD 2>/dev/null || echo "0")

if [ "$COMMITS_AHEAD" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  커밋할 변경사항이 없습니다.${NC}"
    echo -e "${YELLOW}   변경사항을 커밋한 후 다시 시도해주세요.${NC}"
    exit 1
fi

echo -e "${BLUE}📝 커밋 정보:${NC}"
git log --oneline "$REMOTE/$DEFAULT_BRANCH"..HEAD | head -5
echo ""

# PR 제목 입력
echo -e "${YELLOW}PR 제목을 입력하세요 (기본값: $CURRENT_BRANCH):${NC}"
read -p "> " PR_TITLE
PR_TITLE=${PR_TITLE:-$CURRENT_BRANCH}

# PR 본문 입력
echo ""
echo -e "${YELLOW}PR 본문을 입력하세요 (Enter 두 번으로 종료):${NC}"
PR_BODY=""
while IFS= read -r line; do
    if [ -z "$line" ] && [ -z "$PR_BODY" ]; then
        break
    fi
    PR_BODY="${PR_BODY}${line}\n"
done

# GitHub CLI 확인
if command -v gh &> /dev/null; then
    echo ""
    echo -e "${BLUE}🚀 GitHub CLI를 사용하여 PR을 생성합니다...${NC}"
    
    # 브랜치 push
    echo -e "${YELLOW}브랜치를 push하는 중...${NC}"
    git push -u "$REMOTE" "$CURRENT_BRANCH" 2>&1 || {
        echo -e "${RED}❌ Push 실패${NC}"
        exit 1
    }
    
    # PR 생성
    echo -e "${YELLOW}PR을 생성하는 중...${NC}"
    PR_URL=$(gh pr create --title "$PR_TITLE" --body "$PR_BODY" --base "$DEFAULT_BRANCH" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ PR이 생성되었습니다!${NC}"
        echo -e "${GREEN}$PR_URL${NC}"
    else
        echo -e "${RED}❌ PR 생성 실패${NC}"
        echo "$PR_URL"
        exit 1
    fi
else
    # GitHub CLI가 없는 경우
    echo ""
    echo -e "${YELLOW}⚠️  GitHub CLI가 설치되어 있지 않습니다.${NC}"
    echo ""
    echo -e "${BLUE}다음 명령어를 실행하여 PR을 생성하세요:${NC}"
    echo ""
    echo -e "${GREEN}# 1. 브랜치 push${NC}"
    echo -e "   ${YELLOW}git push -u $REMOTE $CURRENT_BRANCH${NC}"
    echo ""
    echo -e "${GREEN}# 2. GitHub에서 PR 생성${NC}"
    echo -e "   ${YELLOW}브라우저에서 다음 URL로 이동:${NC}"
    
    # GitHub URL 추출
    if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/]+)\.git ]]; then
        REPO_OWNER="${BASH_REMATCH[1]}"
        REPO_NAME="${BASH_REMATCH[2]%.git}"
        PR_URL="https://github.com/$REPO_OWNER/$REPO_NAME/compare/$DEFAULT_BRANCH...$CURRENT_BRANCH"
        echo -e "   ${BLUE}$PR_URL${NC}"
    else
        echo -e "   ${YELLOW}GitHub 저장소 페이지에서 'New Pull Request' 클릭${NC}"
    fi
    echo ""
    echo -e "${GREEN}PR 제목:${NC} $PR_TITLE"
    if [ -n "$PR_BODY" ]; then
        echo -e "${GREEN}PR 본문:${NC}"
        echo -e "$PR_BODY"
    fi
fi

echo ""
echo -e "${BLUE}💡 Gemini Code Assist 사용 방법:${NC}"
echo -e "${YELLOW}1. PR이 생성되면 GitHub에서 PR 페이지로 이동${NC}"
echo -e "${YELLOW}2. 'Files changed' 탭에서 코드를 확인${NC}"
echo -e "${YELLOW}3. Gemini Code Assist를 사용하여 코드 리뷰 및 개선${NC}"
echo ""
