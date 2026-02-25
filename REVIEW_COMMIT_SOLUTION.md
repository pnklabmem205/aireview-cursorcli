# 리뷰 파일 커밋 포함 해결 방법

## 문제

리뷰 파일이 커밋에 포함되지 않는 문제가 있었습니다.

**원인:**
- Post-commit hook은 커밋 후에 실행되므로, 리뷰 파일이 커밋에 포함되지 않음

## 해결 방법

### 현재 구현 (타임스탬프 기반)

1. **Pre-commit hook**:
   - 리뷰 실행 후 `reviews/pending-{timestamp}.md` 파일 생성
   - `git add`로 스테이징에 추가
   - 커밋에 포함됨 ✅

2. **Post-commit hook**:
   - 커밋 해시를 얻어서 파일명을 `reviews/{commit-hash}.md`로 변경
   - Git에서 pending 파일 제거하고 새 파일 추가
   - 다음 커밋에 파일명 변경이 반영됨

**장점:**
- 리뷰 파일이 커밋에 포함됨
- 커밋 해시 기반 파일명 사용 가능

**단점:**
- 파일명 변경이 다음 커밋에 반영됨 (1개 커밋 지연)

### 대안 1: 타임스탬프 기반 파일명 유지

Pre-commit hook에서 타임스탬프 기반 파일명을 사용하고, Post-commit hook에서 심볼릭 링크 생성:

```bash
# Pre-commit: reviews/{timestamp}.md 생성 및 git add
# Post-commit: reviews/{commit-hash}.md -> reviews/{timestamp}.md 심볼릭 링크 생성
```

**장점:**
- 파일명 변경 지연 없음
- 커밋 해시로도 접근 가능

**단점:**
- 심볼릭 링크 관리 필요

### 대안 2: 커밋 메시지 기반 파일명

Pre-commit hook에서 커밋 메시지를 기반으로 파일명 생성:

```bash
# 커밋 메시지에서 파일명 생성 (예: reviews/feat-add-review-{timestamp}.md)
COMMIT_MSG=$(git log -1 --pretty=%B)
FILENAME=$(echo "$COMMIT_MSG" | head -1 | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
```

**장점:**
- 커밋 해시 없이도 의미 있는 파일명
- 커밋에 바로 포함됨

**단점:**
- 커밋 해시 기반 접근 불가

### 대안 3: Git Commit Amend 사용

Post-commit hook에서 `git commit --amend`를 사용하여 파일명 변경을 즉시 반영:

```bash
git rm --cached "$PENDING_FILE"
git add "$REVIEW_FILE"
git commit --amend --no-edit
```

**장점:**
- 파일명 변경이 즉시 반영됨

**단점:**
- 커밋 해시가 변경됨 (사용자 경험에 영향)
- 충돌 가능성

## 권장 방법

**현재 구현 (타임스탬프 → 커밋 해시)**을 권장합니다:
- 리뷰 파일이 커밋에 포함됨 ✅
- 커밋 해시 기반 파일명 사용 가능 ✅
- 파일명 변경이 1개 커밋 지연되지만, 실제 사용에는 큰 문제 없음

## 사용 예시

```bash
# 첫 번째 커밋
git add .
git commit -m "feat: add new feature"
# → reviews/pending-1234567890.md가 커밋에 포함됨

# 두 번째 커밋
git add .
git commit -m "fix: bug fix"
# → 이전 커밋의 pending 파일이 reviews/{commit-hash}.md로 변경됨
# → 새 pending 파일이 커밋에 포함됨
```

## 개선 가능한 점

필요하다면 다음 커밋 없이도 파일명을 변경하는 방법을 추가할 수 있습니다:
- `git commit --amend` 사용 (커밋 해시 변경)
- 또는 타임스탬프 기반 파일명 유지
