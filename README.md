# Cursor AI 자동 코드 리뷰 프로젝트

Git push 전에 Cursor CLI Agent를 사용하여 자동으로 코드 리뷰를 수행하는 시스템입니다.

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

```bash
# 코드 변경 후
git add .
git commit -m "변경사항"

# push 시 자동으로 리뷰 실행됨
git push origin main
```

**끝!** 이제 `git push`만 하면 자동으로 AI 리뷰가 실행됩니다.

## 📁 프로젝트 구조

```
.
├── .git/hooks/
│   └── pre-push              # 자동 리뷰 Git hook
├── scripts/
│   └── cursor-review.sh      # 수동 리뷰 스크립트
├── AI_REVIEW_SETUP.md        # 상세 설정 가이드
└── README.md                 # 이 파일
```

## 🔧 주요 기능

- ✅ **자동 리뷰**: `git push` 시 자동으로 코드 리뷰 실행
- ✅ **스마트 감지**: 변경된 파일만 리뷰
- ✅ **유연한 처리**: 리뷰 실패 시에도 강제 진행 옵션 제공
- ✅ **수동 리뷰**: 필요 시 수동으로 리뷰 실행 가능

## 📖 상세 문서

자세한 설정 및 사용법은 [AI_REVIEW_SETUP.md](./AI_REVIEW_SETUP.md)를 참고하세요.

## ⚙️ 설정 비활성화

리뷰를 일시적으로 비활성화하려면:

```bash
mv .git/hooks/pre-push .git/hooks/pre-push.disabled
```

재활성화:

```bash
mv .git/hooks/pre-push.disabled .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```
