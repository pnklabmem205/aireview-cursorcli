# Cursor AI 자동 코드 리뷰 설정 가이드

## 개요

이 프로젝트는 Git push 전에 Cursor CLI Agent를 사용하여 자동으로 코드 리뷰를 수행합니다.

## 🔍 Change Report

### 무엇을 바꿨는가
- Git pre-push hook을 생성하여 push 전 자동 리뷰 트리거
- Cursor CLI Agent를 사용한 코드 리뷰 스크립트 구현
- 수동 리뷰를 위한 별도 스크립트 제공

### 왜 바꿨는가
- 코드 품질을 push 전에 자동으로 검증
- 버그와 보안 이슈를 조기에 발견
- 일관된 코드 리뷰 프로세스 확립

### 기존 대비 얻는 이점
- **자동화**: push만 하면 자동으로 리뷰 진행
- **일관성**: 모든 push에 대해 동일한 리뷰 기준 적용
- **조기 발견**: origin에 push하기 전에 문제 발견
- **유연성**: 리뷰 실패 시에도 강제 진행 옵션 제공

### 운영 시스템으로 갈 때 예상 영향
- CI/CD 파이프라인과 통합 가능
- GitHub Actions 등과 연동하여 PR 리뷰 자동화 가능
- 리뷰 결과를 데이터베이스에 저장하여 품질 메트릭 수집 가능

### 되돌릴 수 있는지
**Yes** - `.git/hooks/pre-push` 파일을 삭제하거나 이름을 변경하면 됩니다.

---

## 사전 요구사항

1. **Cursor CLI 설치 확인**
   ```bash
   cursor --version
   ```

2. **Cursor 인증 확인**
   ```bash
   cursor agent status
   ```
   인증이 안 되어 있다면:
   ```bash
   cursor agent login
   ```

3. **Git 저장소 초기화** (이미 되어 있음)
   ```bash
   git init
   ```

---

## 설정 방법

### 1. 자동 리뷰 (Pre-push Hook)

이미 설정되어 있습니다. `git push` 명령을 실행하면 자동으로 리뷰가 실행됩니다.

**동작 방식:**
1. `git push` 실행
2. Pre-push hook이 자동으로 트리거됨
3. 변경된 파일과 diff 추출
4. Cursor CLI Agent로 리뷰 실행
5. 리뷰 결과에 따라:
   - **PASS**: 자동으로 origin에 push 진행
   - **FAIL**: 사용자에게 확인 후 진행 여부 결정
   - **WARNING**: 사용자에게 확인 후 진행

**Hook 비활성화:**
```bash
mv .git/hooks/pre-push .git/hooks/pre-push.disabled
```

**Hook 재활성화:**
```bash
mv .git/hooks/pre-push.disabled .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

### 2. 수동 리뷰 스크립트

push 전에 수동으로 리뷰를 실행하고 싶을 때:

```bash
./scripts/cursor-review.sh
```

**옵션:**
- 스테이징된 변경사항 리뷰
- 마지막 커밋 리뷰
- 특정 커밋 범위 리뷰
- 원격 브랜치와 비교 리뷰

---

## 사용 예시

### 기본 사용 (자동 리뷰)

```bash
# 코드 변경 후
git add .
git commit -m "새 기능 추가"

# push 시 자동으로 리뷰 실행
git push origin main
```

**출력 예시:**
```
╔════════════════════════════════════════╗
║   Cursor AI 코드 리뷰 시작            ║
╚════════════════════════════════════════╝

📝 변경된 파일 목록:
  • src/main.ts
  • src/utils.ts

🤖 Cursor AI Agent가 코드를 리뷰 중입니다...

╔════════════════════════════════════════╗
║         AI 리뷰 결과                   ║
╚════════════════════════════════════════╝

## 리뷰 결과

**상태**: PASS
**요약**: 코드 품질이 양호하며 특별한 문제가 없습니다.

✅ 리뷰 통과!
🚀 origin에 push를 진행합니다...
```

### 리뷰 실패 시

```
╔════════════════════════════════════════╗
║  ❌ 리뷰 실패: 중요한 문제 발견        ║
╚════════════════════════════════════════╝

⚠️  문제를 수정한 후 다시 push해주세요.
리뷰를 무시하고 강제로 push를 계속하시겠습니까? (y/N)
```

---

## 리뷰 기준

현재 리뷰는 다음 항목을 확인합니다:

1. **버그 및 잠재적 오류**
   - 논리 오류
   - 예외 처리 누락
   - 경계 조건 처리

2. **코드 품질**
   - 가독성
   - 네이밍 규칙
   - 코드 중복

3. **보안**
   - SQL Injection
   - XSS 취약점
   - 인증/인가 문제

4. **성능**
   - 비효율적인 알고리즘
   - 불필요한 반복
   - 메모리 누수 가능성

5. **베스트 프랙티스**
   - 프레임워크/라이브러리 사용 규칙
   - 아키텍처 패턴 준수

6. **테스트 가능성**
   - 테스트하기 어려운 구조
   - Mock 가능성

---

## 커스터마이징

### 리뷰 프롬프트 수정

`.git/hooks/pre-push` 파일에서 `REVIEW_PROMPT` 변수를 수정하여 리뷰 기준을 변경할 수 있습니다.

### 리뷰 결과 파싱 로직 수정

리뷰 결과에서 FAIL/WARNING을 감지하는 로직을 수정하려면 `.git/hooks/pre-push` 파일의 다음 부분을 수정하세요:

```bash
# 리뷰 결과에서 FAIL 상태 확인
if echo "$REVIEW_OUTPUT" | grep -qiE "(상태.*FAIL|FAIL|❌.*중요|중요.*문제|critical.*issue)"; then
    # ...
fi
```

### Cursor Agent 옵션 변경

`.git/hooks/pre-push`에서 Cursor CLI 명령어 옵션을 수정할 수 있습니다:

```bash
cursor agent --print --output-format text --workspace "$(pwd)" --trust "$REVIEW_PROMPT"
```

**주요 옵션:**
- `--model <model>`: 사용할 모델 지정 (예: `sonnet-4`)
- `--output-format json`: JSON 형식으로 결과 받기
- `--plan`: 읽기 전용 모드 (수정 없이 분석만)

---

## 문제 해결

### 1. "Cursor CLI not found" 오류

```bash
# Cursor CLI 경로 확인
which cursor

# PATH에 추가 (필요한 경우)
export PATH="$PATH:/home/pnkslabserver/.cursor-server/bin/linux-x64/2ca326e0d1ce10956aea33d54c0e2d8c13c58a30/bin/remote-cli"
```

### 2. 인증 오류

```bash
cursor agent login
```

### 3. 리뷰가 너무 느림

- `--model` 옵션으로 더 빠른 모델 사용
- 리뷰 범위를 줄이기 (특정 파일만 리뷰)
- 리뷰 기준을 간소화

### 4. Hook이 실행되지 않음

```bash
# 실행 권한 확인
ls -la .git/hooks/pre-push

# 실행 권한 부여
chmod +x .git/hooks/pre-push
```

### 5. 리뷰 결과 파싱 실패

리뷰 결과 형식이 예상과 다를 수 있습니다. `.git/hooks/pre-push`의 파싱 로직을 조정하거나, 리뷰 프롬프트에서 출력 형식을 더 명확하게 지정하세요.

---

## 고급 사용법

### 특정 브랜치에서만 리뷰 활성화

`.git/hooks/pre-push` 파일 시작 부분에 추가:

```bash
# main 브랜치에서만 리뷰 실행
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    exit 0
fi
```

### 리뷰 결과를 파일로 저장

```bash
REVIEW_OUTPUT=$(cursor agent --print ...)
echo "$REVIEW_OUTPUT" > ".git/review-$(date +%Y%m%d-%H%M%S).txt"
```

### CI/CD 통합

GitHub Actions 예시:

```yaml
name: AI Code Review
on: [push, pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Cursor AI Review
        run: |
          cursor agent --print --workspace . --trust "코드 리뷰를 수행하세요"
```

---

## 참고 자료

- [Cursor CLI 문서](https://docs.cursor.com/ko/cli)
- [Cursor Agent 문서](https://docs.cursor.com/ko/agent)
- [Git Hooks 가이드](https://git-scm.com/book/ko/v2/Git%EB%A7%9B%EC%8B%9C-Git-Hooks)

---

## 라이선스

이 설정은 프로젝트의 라이선스를 따릅니다.
