#!/usr/bin/env bash
# clone 後に fixture/demo-project を git リポとして初期化（コミット2件）
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)/fixture/demo-project"
cd "$DIR"

if [ -e "$DIR/.git" ]; then
  echo "✅ fixture/demo-project は既に git リポです"
  git -C "$DIR" log --oneline -3
  exit 0
fi

git init -q
git config user.email "a1-w1-minimal@local.test"
git config user.name "W1 Demo"

cat > README.md <<'EOF'
# demo-project

`daily-git-sync` 検証用のサンプル git リポジトリ。
EOF

git add README.md
git commit -q -m "feat: initial demo commit"
echo "" >> README.md
echo "sample line for second commit" >> README.md
git add README.md
git commit -q -m "feat: second commit for daily-git test"

echo "✅ fixture/demo-project を初期化しました"
git log --oneline -3