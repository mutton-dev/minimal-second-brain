#!/usr/bin/env bash
# 最小版: テンプレから当日デイリーノートを作成（carry-over なし）
set -uo pipefail

VAULT="${VAULT:-$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/.." && pwd)")}"
TODAY="${TODAY:-$(TZ=Asia/Tokyo date +%Y-%m-%d)}"
DAILY="$VAULT/10_Daily/${TODAY}.md"

if [ -f "$DAILY" ]; then
  echo "📅 10_Daily/${TODAY}.md は既に存在します (skip)"
  exit 0
fi

TEMPLATE="$VAULT/90_Templates/daily.md"
if [ ! -f "$TEMPLATE" ]; then
  echo "❌ テンプレート $TEMPLATE が見つかりません" >&2
  exit 1
fi

mkdir -p "$VAULT/10_Daily"
sed "s/YYYY-MM-DD/$TODAY/g" "$TEMPLATE" > "$DAILY"
echo "📅 10_Daily/${TODAY}.md を作成しました (minimal: carry-over なし)"