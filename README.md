# minimal-second-brain (W1 再現用)

Zenn 記事「[Claude Code で Obsidian デイリーノートに「自分の Git コミット」を自動追記する — `/daily:git` 最小構成](https://zenn.dev/mutton/articles/f3fa9f249e9c77)」の**最小再現リポジトリ**。

本番 second-brain Vault とは別。`/daily:git` 相当を **1リポジトリ** で試す。

## 前提

- macOS or Linux
- git, python3, bash
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) または手動で `bin/daily-git-sync.sh` を実行

## 5ステップ（記事と同じ）

```bash
git clone https://github.com/mutton-dev/minimal-second-brain.git
cd minimal-second-brain

# 1. この Vault を Obsidian で開く（またはエディタで編集）

# 2. テスト用リポジトリ（fixture）を初期化
bash bin/setup-fixture.sh

# 3. 当日デイリーノート作成
bash bin/daily-init.sh

# 4. Git コミットを取り込み（絶対パスで指定）
bash bin/daily-git-sync.sh "$(pwd)/fixture/demo-project"

# 5. 10_Daily/YYYY-MM-DD.md の ## やったこと を確認
#    もう一度 4 を実行 → 行が増えず置換のみ（冪等）
```

Claude Code からは:

```
/daily
/daily:git /absolute/path/to/minimal-second-brain/fixture/demo-project
```

## 構成

```
├── 10_Daily/              # デイリーノート
├── 90_Templates/daily.md
├── .claude/commands/      # /daily, /daily:git
├── bin/
│   ├── daily-init.sh
│   ├── daily-git-sync.sh
│   ├── daily-target-dates.sh
│   ├── get-pc-name.sh
│   └── setup-fixture.sh
└── fixture/demo-project/  # サンプル git リポ（2コミット）
```

## W2 以降（このリポには含めない）

- `/daily:git all`、マルチPC、`/daily:all`
- Discord / X / Notion 連携
- 記事ドラフト・X 原稿（作者の Vault 側で管理）

## ライセンス

MIT（テンプレート・スクリプト）。