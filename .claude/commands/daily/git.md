---
description: 指定リポジトリの過去7日の自分のコミットをデイリーノートに反映（W1 最小版・単一 path）
---

指定した **1つの** git リポジトリ (+ worktree) の過去7日の自分のコミットを取り込む。
当日複数回実行しても重複しない（冪等）。

## 手順

### Step 1: 引数を確認

`$ARGUMENTS` が空なら以下を表示して終了:

```
使い方:
  /daily:git <path>    単一リポジトリ（絶対パス推奨）

例:
  /daily:git /home/you/workspace/demo-project
```

`all` や複数 path は W1 では未対応。`bin/daily-git-sync.sh` を1回だけ実行する。

### Step 2: 同期実行

```bash
VAULT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
bash "$VAULT/bin/daily-git-sync.sh" "$ARGUMENTS"
```

### Step 3: レポート

スクリプト出力をそのままユーザーに伝える。`10_Daily/YYYY-MM-DD.md` の `## やったこと` に `(git)` bullet が入っていることを確認する。

## 注意

- デイリーノートが無い場合は `daily-init.sh` が自動実行される
- マーカー `<!-- daily:summary:git:* -->` 内のみ置き換え