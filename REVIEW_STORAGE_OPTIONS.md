# 리뷰 저장 위치 옵션

## 현재 설정: `.git/reviews/` (로컬 전용)

**특징:**
- ✅ Git에 추적되지 않음 (`.git` 디렉토리 안)
- ✅ Push되지 않음
- ✅ 로컬에만 저장
- ❌ 다른 사람이 볼 수 없음
- ❌ 다른 환경에서 클론해도 리뷰 이력이 없음

## 옵션 1: 프로젝트 루트 `reviews/` (공유 가능)

**특징:**
- ✅ Git에 추적됨
- ✅ Push되어 다른 사람도 볼 수 있음
- ✅ 다른 환경에서도 리뷰 이력 유지
- ⚠️ 리뷰 파일이 저장소에 포함됨 (용량 증가)
- ⚠️ 리뷰 내용이 공개됨

**사용 시나리오:**
- 팀과 리뷰 이력을 공유하고 싶을 때
- CI/CD에서 리뷰 이력을 확인하고 싶을 때
- 리뷰 이력을 문서화하고 싶을 때

## 옵션 2: 현재 방식 유지 (로컬 전용)

**사용 시나리오:**
- 개인 개발 환경에서만 사용
- 리뷰 내용을 공유할 필요가 없을 때
- 저장소 크기를 최소화하고 싶을 때

## 설정 변경 방법

### 옵션 1로 변경 (공유 가능)

1. Hook 파일 수정:
   - `.git/hooks/post-commit`에서 `REVIEWS_DIR=".git/reviews"`를 `REVIEWS_DIR="reviews"`로 변경
   - `.git/hooks/pre-commit`에서도 동일하게 변경
   - `.git/hooks/pre-push`에서도 동일하게 변경

2. `.gitignore`에 추가 (선택적):
   ```bash
   # 리뷰 디렉토리는 Git에 포함하므로 ignore하지 않음
   # reviews/
   ```

3. 기존 리뷰 이동 (선택적):
   ```bash
   if [ -d ".git/reviews" ]; then
       mv .git/reviews reviews
       git add reviews/
       git commit -m "Move reviews to project root for sharing"
   fi
   ```

### 옵션 2 유지 (현재 방식)

현재 설정을 그대로 사용하면 됩니다.

## 권장 사항

- **개인 프로젝트**: 현재 방식 (`.git/reviews/`) 유지
- **팀 프로젝트**: `reviews/`로 변경하여 공유
- **오픈소스**: `reviews/`로 변경하여 투명성 확보
