# 리뷰 시스템 테스트 가이드

## 현재 상태

✅ Pre-push hook이 정상적으로 작동합니다!
✅ 파일 감지 및 Cursor AI 리뷰가 실행됩니다.

## 테스트 방법

### 방법 1: 원격 저장소 설정 후 push

```bash
# 원격 저장소 추가 (예시)
git remote add origin https://github.com/your-username/your-repo.git

# 변경사항 커밋
git add .
git commit -m "테스트 커밋"

# push 시 자동으로 리뷰 실행됨
git push origin master
```

### 방법 2: 수동 리뷰 스크립트 사용

원격 저장소 없이도 리뷰를 테스트할 수 있습니다:

```bash
./scripts/cursor-review.sh
```

옵션 2 (마지막 커밋)를 선택하면 현재 커밋을 리뷰합니다.

### 방법 3: Hook 직접 테스트

```bash
# 새 브랜치 push 시뮬레이션
echo "refs/heads/master $(git rev-parse HEAD) refs/heads/master 0000000000000000000000000000000000000000" | \
  bash .git/hooks/pre-push origin https://github.com/test/test.git
```

## 확인 사항

리뷰가 실행되면 다음과 같은 출력을 볼 수 있습니다:

```
╔════════════════════════════════════════╗
║   Cursor AI 코드 리뷰 시작            ║
╚════════════════════════════════════════╝

📝 변경된 파일 목록:
  • 파일1
  • 파일2

🤖 Cursor AI Agent가 코드를 리뷰 중입니다...

╔════════════════════════════════════════╗
║         AI 리뷰 결과                   ║
╚════════════════════════════════════════╝
```

## 문제 해결

### "변경된 파일이 없습니다" 메시지가 나오는 경우

1. 실제로 변경사항이 있는지 확인:
   ```bash
   git status
   git log --oneline -5
   ```

2. Hook이 제대로 실행되는지 확인:
   ```bash
   ls -la .git/hooks/pre-push
   chmod +x .git/hooks/pre-push
   ```

3. 수동으로 테스트:
   ```bash
   ./scripts/cursor-review.sh
   ```

### 원격 저장소가 없는 경우

원격 저장소가 없으면 `git push` 자체가 실행되지 않아 hook이 트리거되지 않습니다.

해결 방법:
- 원격 저장소를 추가하거나
- 수동 리뷰 스크립트(`./scripts/cursor-review.sh`)를 사용하세요.
