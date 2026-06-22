# minimal-second-brain — Claude Code 運用ルール（抜粋）

## この Vault とは

Obsidian デイリーノートに **Git コミットだけ** を流し込む最小構成。記事 W1 用。

## フォルダ

| フォルダ | 用途 |
|---|---|
| `10_Daily/` | デイリーノート `YYYY-MM-DD.md` |
| `90_Templates/` | テンプレート（直接編集しない） |
| `bin/` | 共有スクリプト |
| `.claude/commands/` | `/daily`, `/daily:git` |

## コマンド

- `/daily` — `bin/daily-init.sh` で当日ノート作成
- `/daily:git <path>` — `bin/daily-git-sync.sh <path>` で過去7日の自分のコミットを `## やったこと` に反映

## マーカー規則

- `<!-- daily:summary:git:{host}:start/end -->` 内だけ置き換え（手動 bullet を壊さない）
- 同日再実行 = 冪等（重複しない）

## やってはいけないこと

- `.env` やシークレットをコミットしない
- `10_Daily/` 以外の資産を無確認で大量変更しない