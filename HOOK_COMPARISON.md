# Pre-commit vs Pre-push Hook 비교

## 두 Hook의 차이점

### Pre-commit Hook (권장) ✅

**실행 시점**: `git commit` 실행 시
**장점**:
- ✅ **로컬에서 먼저 검증**: 커밋 전에 문제를 발견
- ✅ **원격 저장소 불필요**: 원격 저장소 없이도 작동
- ✅ **빠른 피드백**: 커밋 직전에 리뷰 받음
- ✅ **작은 단위 리뷰**: 각 커밋마다 리뷰 가능
- ✅ **히스토리 깔끔**: 문제 있는 코드가 커밋되지 않음

**단점**:
- ⚠️ 커밋할 때마다 리뷰 실행 (시간 소요)
- ⚠️ 여러 커밋을 한 번에 리뷰 불가

**사용 시나리오**:
- 로컬에서 개발 중일 때
- 각 커밋마다 품질 검증이 필요할 때
- 원격 저장소 설정 전에 리뷰하고 싶을 때

### Pre-push Hook

**실행 시점**: `git push` 실행 시
**장점**:
- ✅ **일괄 리뷰**: 여러 커밋을 한 번에 리뷰
- ✅ **Push 전 최종 검증**: Origin에 올라가기 전 확인
- ✅ **커밋 속도**: 커밋은 빠르게, push 전에만 리뷰

**단점**:
- ⚠️ **원격 저장소 필요**: 원격 저장소가 없으면 실행 안 됨
- ⚠️ **늦은 피드백**: 여러 커밋 후에야 문제 발견
- ⚠️ **히스토리 오염**: 문제 있는 커밋이 이미 로컬에 존재

**사용 시나리오**:
- 여러 커밋을 한 번에 리뷰하고 싶을 때
- Origin에 push하기 전 최종 검증이 필요할 때
- 팀과 공유하기 전에 리뷰하고 싶을 때

## 권장 설정

### 옵션 1: Pre-commit만 사용 (권장) ⭐

로컬에서 먼저 검증하고 싶다면 Pre-commit hook만 사용하세요.

```bash
# Pre-push hook 비활성화
mv .git/hooks/pre-push .git/hooks/pre-push.disabled

# Pre-commit hook 활성화 (이미 활성화됨)
# .git/hooks/pre-commit
```

**사용법**:
```bash
git add .
git commit -m "변경사항"  # 여기서 자동 리뷰 실행
```

### 옵션 2: Pre-commit + Pre-push 함께 사용

두 Hook을 모두 사용하면:
- Pre-commit: 각 커밋마다 빠른 리뷰
- Pre-push: 여러 커밋을 한 번에 최종 리뷰

**사용법**:
```bash
git add .
git commit -m "변경사항"  # Pre-commit 리뷰
git commit -m "추가 변경"  # Pre-commit 리뷰
git push origin master     # Pre-push 리뷰 (모든 커밋)
```

### 옵션 3: Pre-push만 사용

커밋은 빠르게 하고, push 전에만 리뷰하고 싶다면:

```bash
# Pre-commit hook 비활성화
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled

# Pre-push hook 활성화 (이미 활성화됨)
# .git/hooks/pre-push
```

**사용법**:
```bash
git add .
git commit -m "변경사항"  # 리뷰 없이 빠르게 커밋
git push origin master   # 여기서 자동 리뷰 실행
```

## 현재 설정 확인

```bash
# 활성화된 hook 확인
ls -la .git/hooks/pre-commit
ls -la .git/hooks/pre-push

# 비활성화된 hook 확인
ls -la .git/hooks/*.disabled
```

## Hook 전환하기

### Pre-commit으로 전환 (권장)

```bash
# Pre-push 비활성화
mv .git/hooks/pre-push .git/hooks/pre-push.disabled

# Pre-commit 활성화 확인
chmod +x .git/hooks/pre-commit
```

### Pre-push로 전환

```bash
# Pre-commit 비활성화
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled

# Pre-push 활성화 확인
chmod +x .git/hooks/pre-push
```

## 성능 고려사항

### Pre-commit Hook
- **빠른 리뷰**: 각 커밋마다 실행되므로 빠른 피드백이 중요
- **선택적 리뷰**: 특정 파일만 리뷰하도록 필터링 가능
- **비동기 옵션**: 필요시 리뷰를 비동기로 실행 가능

### Pre-push Hook
- **일괄 리뷰**: 여러 커밋을 한 번에 리뷰하므로 시간이 더 걸릴 수 있음
- **전체 범위**: Push할 모든 커밋을 리뷰

## 결론

**로컬에서 먼저 검증하고 싶다면 → Pre-commit Hook 사용 (권장)** ✅

이미 Pre-commit hook이 설정되어 있으므로, `git commit`만 하면 자동으로 리뷰가 실행됩니다!
