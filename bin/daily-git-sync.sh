#!/usr/bin/env bash
# W1 最小版: 単一 git リポジトリの過去7日コミットをデイリーノートに同期（冪等）
set -euo pipefail

REPO_PATH="${1:-}"
if [ -z "$REPO_PATH" ]; then
  echo "使い方: bash bin/daily-git-sync.sh <git-repo-path>" >&2
  exit 1
fi

REPO_PATH=$(cd "$REPO_PATH" && pwd)
VAULT="${VAULT:-$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "$0")/.." && pwd)")}"
TODAY="${TODAY:-$(TZ=Asia/Tokyo date +%Y-%m-%d)}"
HOST=$(bash "$VAULT/bin/get-pc-name.sh")

git -C "$REPO_PATH" rev-parse --git-dir >/dev/null 2>&1 || {
  echo "❌ $REPO_PATH は git リポジトリではありません" >&2
  exit 1
}

SINCE_DATE=$(python3 -c "from datetime import date,timedelta;print((date.fromisoformat('$TODAY')-timedelta(days=6)).isoformat())")

EXTRA_EMAILS=""
if [ -f "$VAULT/bin/git-authors.txt" ]; then
  EXTRA_EMAILS=$(grep -v '^#' "$VAULT/bin/git-authors.txt" | grep -v '^$' || true)
fi

PRIMARY_EMAIL=$(git -C "$REPO_PATH" config user.email 2>/dev/null || git config user.email || true)
ALL_EMAILS=$(printf '%s\n%s' "$PRIMARY_EMAIL" "$EXTRA_EMAILS" | sort -u | grep -v '^$' || true)

AUTHOR_FLAGS=""
while IFS= read -r em; do
  [ -n "$em" ] && AUTHOR_FLAGS="$AUTHOR_FLAGS --author=$em"
done <<< "$ALL_EMAILS"

COMMITS=""
WORKTREES=$(git -C "$REPO_PATH" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2}')
[ -z "$WORKTREES" ] && WORKTREES="$REPO_PATH"

while IFS= read -r WT; do
  [ -z "$WT" ] && continue
  C=$(git -C "$WT" log \
    --since="${SINCE_DATE} 00:00" \
    $AUTHOR_FLAGS \
    --no-merges \
    --all \
    --format=$'%H\t%h\t%aI\t%s\t'"$WT" \
    2>/dev/null || true)
  [ -n "$C" ] && COMMITS+="$C"$'\n'
done <<< "$WORKTREES"

UNIQUE=$(echo "$COMMITS" | grep -v '^$' | sort -t$'\t' -k1,1 -u | sort -t$'\t' -k3,3)

COMMITS_JSON=$(echo "$UNIQUE" | python3 -c "
import json, sys
from datetime import datetime, timezone, timedelta
from pathlib import Path

JST = timezone(timedelta(hours=9))
commits_by_date = {}

for line in sys.stdin:
    parts = line.strip().split('\t')
    if len(parts) < 5:
        continue
    _, short, ts_str, subject, wt = parts[0], parts[1], parts[2], parts[3], parts[4]
    ts = datetime.fromisoformat(ts_str).astimezone(JST)
    date = ts.strftime('%Y-%m-%d')
    wt_name = Path(wt).name
    commits_by_date.setdefault(date, []).append({
        'hhmm': ts.strftime('%H:%M'),
        'short': short,
        'subject': subject,
        'wt': wt_name
    })

print(json.dumps(commits_by_date))
")

TOTAL=$(echo "$COMMITS_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(sum(len(v) for v in d.values()))")

bash "$VAULT/bin/daily-init.sh"
DAILY="$VAULT/10_Daily/${TODAY}.md"

NOW_JST=$(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M JST')
REPO_NAME=$(basename "$REPO_PATH")

python3 - "$DAILY" "$COMMITS_JSON" "$TODAY" "$HOST" "$NOW_JST" "$REPO_NAME" "$TOTAL" <<'PYEOF'
import json, re, sys
from pathlib import Path

daily_path, commits_json, today, host, now_jst, repo_name, total = sys.argv[1:8]
commits_by_date = json.loads(commits_json)
total = int(total)

with open(daily_path, encoding="utf-8") as f:
    content = f.read()

today_commits = commits_by_date.get(today, [])

# --- ログ詳細 ---
detail_lines = []
if today_commits:
    detail_lines.append(f"### {today} (今日) — {len(today_commits)}件")
    for c in today_commits:
        detail_lines.append(f"- {c['hhmm']} `{c['short']}` {c['subject']} ({c['wt']})")

detail_body = "\n".join([
    f"#### {host}",
    "",
    f"<!-- 最終取得: {now_jst} / 過去7日 ({repo_name}) -->",
    "",
] + detail_lines)

detail_start = f"<!-- daily:detail:git:{host}:start -->"
detail_end = f"<!-- daily:detail:git:{host}:end -->"
detail_block = f"{detail_start}\n{detail_body}\n{detail_end}"

if "## ログ詳細" not in content:
    content = content.rstrip() + "\n\n## ログ詳細\n\n"
if "### Git コミット" not in content:
    content = content.rstrip() + "\n\n### Git コミット\n\n" + detail_block + "\n"
elif detail_start in content:
    content = re.sub(
        re.escape(detail_start) + r".*?" + re.escape(detail_end),
        detail_block,
        content,
        flags=re.DOTALL,
    )
else:
    content = re.sub(
        r"(### Git コミット\s*\n)",
        r"\1" + detail_block + "\n",
        content,
        count=1,
    )

# --- やったこと 要約 ---
summary_bullets = []
for c in today_commits[:5]:
    summary_bullets.append(f"- (git) `{c['short']}` {c['subject']} ({repo_name})")
if not summary_bullets and total == 0:
    pass
elif not summary_bullets:
    summary_bullets.append(f"- (git) 過去7日 {total}件のコミット（今日分なし）")

if summary_bullets:
    summary_inner = "\n".join(summary_bullets)
    child_start = f"<!-- daily:summary:git:{host}:start -->"
    child_end = f"<!-- daily:summary:git:{host}:end -->"
    parent_start = "<!-- daily:summary:git:start -->"
    parent_end = "<!-- daily:summary:git:end -->"
    child_block = f"{child_start}\n{summary_inner}\n{child_end}"

    if child_start in content:
        content = re.sub(
            re.escape(child_start) + r".*?" + re.escape(child_end),
            child_block,
            content,
            flags=re.DOTALL,
        )
    elif parent_start in content:
        content = content.replace(parent_end, f"{child_block}\n{parent_end}")
    else:
        marker = "\n".join([
            parent_start,
            child_block,
            parent_end,
            "",
        ])
        if "## やったこと" in content:
            content = re.sub(
                r"(## やったこと\s*\n)",
                r"\1" + marker,
                content,
                count=1,
            )

# --- updated ---
content = re.sub(
    r"^updated: \d{4}-\d{2}-\d{2}",
    f"updated: {today}",
    content,
    count=1,
    flags=re.MULTILINE,
)

with open(daily_path, "w", encoding="utf-8") as f:
    f.write(content)

# state files
bin_dir = Path(daily_path).parents[1] / "bin"
summary_text = "\n".join(summary_bullets) + ("\n" if summary_bullets else "")
(bin_dir / f"last-git-{host}-summary.txt").write_text(summary_text, encoding="utf-8")
(bin_dir / f"last-git-{host}.txt").write_text(detail_body + "\n", encoding="utf-8")

print(f"✅ Git コミットを取り込みました (今日: {len(today_commits)}件 / 過去7日合計: {total}件)")
print(f"📄 {daily_path}")
PYEOF