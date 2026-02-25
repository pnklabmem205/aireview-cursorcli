# Cursor AI 자동 코드 리뷰 프로젝트

Git 커밋/푸시 전에 Cursor CLI Agent를 사용하여 자동으로 코드 리뷰를 수행하는 시스템입니다.

**권장**: Pre-commit hook 사용 (로컬에서 먼저 검증)

## 🚀 빠른 시작

### 1. Cursor CLI 인증 확인

```bash
cursor agent status
```

인증이 안 되어 있다면:
```bash
cursor agent login
```

### 2. 바로 사용하기

**Pre-commit Hook (권장)** - 커밋 전에 리뷰:
```bash
# 코드 변경 후
git add .
git commit -m "변경사항"  # 여기서 자동으로 리뷰 실행됨!
```

**Pre-push Hook** - Push 전에 리뷰:
```bash
git add .
git commit -m "변경사항"
git push origin main  # 여기서 자동으로 리뷰 실행됨
```

**끝!** 이제 `git commit` 또는 `git push`만 하면 자동으로 AI 리뷰가 실행됩니다.

## 📁 프로젝트 구조

```
.
├── .git/hooks/
│   ├── pre-commit            # 커밋 전 자동 리뷰 (권장)
│   └── pre-push              # Push 전 자동 리뷰
├── scripts/
│   ├── cursor-review.sh      # 수동 리뷰 스크립트
│   ├── view-review.sh        # 저장된 리뷰 조회 스크립트
│   └── switch-review-storage.sh  # 리뷰 저장 위치 전환 스크립트
├── .git/reviews/             # 리뷰 결과 저장 디렉토리 (로컬 전용)
└── reviews/                  # 리뷰 결과 저장 디렉토리 (공유 가능, 선택적)
├── AI_REVIEW_SETUP.md        # 상세 설정 가이드
├── HOOK_COMPARISON.md        # Pre-commit vs Pre-push 비교
└── README.md                 # 이 파일
```

## 🔧 주요 기능

- ✅ **자동 리뷰**: `git commit` 또는 `git push` 시 자동으로 코드 리뷰 실행
- ✅ **로컬 검증**: Pre-commit hook으로 커밋 전에 먼저 검증 (권장)
- ✅ **스마트 감지**: 변경된 파일만 리뷰
- ✅ **리뷰 저장**: 각 커밋별로 리뷰 결과 자동 저장
- ✅ **리뷰 조회**: 저장된 리뷰 결과를 쉽게 조회 가능
- ✅ **유연한 처리**: 리뷰 실패 시에도 강제 진행 옵션 제공
- ✅ **수동 리뷰**: 필요 시 수동으로 리뷰 실행 가능

## 📖 상세 문서

자세한 설정 및 사용법은 [AI_REVIEW_SETUP.md](./AI_REVIEW_SETUP.md)를 참고하세요.

## ⚙️ 설정 비활성화

### Pre-commit Hook 비활성화
```bash
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled
```

### Pre-push Hook 비활성화
```bash
mv .git/hooks/pre-push .git/hooks/pre-push.disabled
```

### 재활성화
```bash
mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## 📝 저장된 리뷰 조회

리뷰 결과는 각 커밋별로 자동으로 저장됩니다:

```bash
# 저장된 리뷰 조회
./scripts/view-review.sh
```

**옵션:**
- 최근 커밋의 리뷰
- 특정 커밋 해시의 리뷰
- 모든 리뷰 목록
- 특정 파일 검색

리뷰는 기본적으로 `.git/reviews/` 디렉토리에 커밋 해시별로 저장됩니다.

**참고**: `.git/reviews/`는 Git에 추적되지 않아 push되지 않습니다 (로컬 전용).
다른 사람과 공유하려면 `reviews/` 디렉토리로 전환하세요:

```bash
./scripts/switch-review-storage.sh
```

자세한 내용은 [REVIEW_STORAGE_OPTIONS.md](./REVIEW_STORAGE_OPTIONS.md)를 참고하세요.

## 📚 더 알아보기

- [Pre-commit vs Pre-push 비교](./HOOK_COMPARISON.md) - 어떤 Hook을 사용할지 결정
- [상세 설정 가이드](./AI_REVIEW_SETUP.md) - 고급 설정 및 커스터마이징
