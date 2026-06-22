---
description: 今日のデイリーノートを作成または追記する
---

今日の日付は $CURRENT_DATE (YYYY-MM-DD 形式で使う) です。

## 手順

1. `10_Daily/YYYY-MM-DD.md` が存在するか確認する

2. **存在しない場合**:

   ```bash
   VAULT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
   bash "$VAULT/bin/daily-init.sh"
   ```

   完了報告:
   ```
   📅 10_Daily/YYYY-MM-DD.md を作成しました
   ```

3. **存在する場合**: 既存ファイルを読み込んで内容を表示する。

## 注意

- フロントマターの `updated` を今日の日付に更新する
- 既存の内容を削除・上書きしない