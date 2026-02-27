# Gemini Code Assist 사용 가이드

## PR 생성 및 Gemini Code Assist 사용하기

### 1. 변경사항 만들기

```bash
# 현재 브랜치 확인
git branch

# 변경사항 만들기 (예시)
echo "# Gemini Code Assist 테스트" > gemini-test.md
git add gemini-test.md
git commit -m "feat: add gemini code assist test"
```

### 2. PR 생성

#### 방법 1: 스크립트 사용 (권장)

```bash
./scripts/create-pr.sh
```

스크립트가 자동으로:
- 브랜치를 origin에 push
- GitHub CLI로 PR 생성 (설치되어 있는 경우)
- 또는 PR 생성 URL 제공

#### 방법 2: 수동 PR 생성

```bash
# 브랜치 push
git push -u origin feature/gemini-code-assist-test

# GitHub에서 PR 생성
# 브라우저에서 다음 URL로 이동:
# https://github.com/pnklabmem205/aireview-cursorcli/compare/main...feature/gemini-code-assist-test
```

### 3. Gemini Code Assist 사용하기

PR이 생성되면:

1. **GitHub PR 페이지로 이동**
   - PR 목록에서 생성된 PR 클릭
   - 또는 스크립트가 제공한 PR URL로 이동

2. **Gemini Code Assist 활성화**
   - PR 페이지에서 "Files changed" 탭 클릭
   - 코드 변경사항 확인
   - Gemini Code Assist 아이콘/버튼 클릭 (GitHub UI에서 제공되는 경우)

3. **코드 리뷰 요청**
   - 특정 파일이나 라인 선택
   - "Ask Gemini" 또는 "Review with Gemini" 클릭
   - 리뷰 요청 입력

4. **코드 개선 제안 받기**
   - Gemini가 코드를 분석하고 개선 제안 제공
   - 제안을 적용하거나 거부

### 4. Gemini Code Assist 기능

- **코드 리뷰**: 변경사항에 대한 자동 리뷰
- **버그 발견**: 잠재적 버그 및 문제점 발견
- **코드 개선**: 성능, 가독성, 보안 개선 제안
- **설명 생성**: 복잡한 코드에 대한 설명
- **테스트 생성**: 테스트 코드 자동 생성

### 5. PR 업데이트

Gemini Code Assist로 받은 제안을 적용한 후:

```bash
# 변경사항 커밋
git add .
git commit -m "fix: apply gemini code assist suggestions"

# PR에 자동으로 반영됨 (같은 브랜치에 push)
git push
```

### 6. PR 머지

리뷰가 완료되면:

```bash
# GitHub에서 "Merge pull request" 클릭
# 또는 GitHub CLI 사용:
gh pr merge <PR_NUMBER> --merge
```

## 참고

- Gemini Code Assist는 GitHub의 기능이므로 GitHub 저장소에서만 사용 가능합니다
- GitHub Copilot과 유사하지만 Gemini 기반입니다
- PR에서만 사용 가능할 수도 있고, 코드 편집기에서도 사용 가능할 수 있습니다

## 문제 해결

### GitHub CLI가 없는 경우

```bash
# 설치 (Ubuntu/Debian)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# 인증
gh auth login
```

### PR 생성 실패

- 원격 저장소가 올바르게 설정되어 있는지 확인
- 브랜치가 이미 push되어 있는지 확인
- GitHub 인증이 되어 있는지 확인
