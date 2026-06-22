#!/usr/bin/env bash
set -uo pipefail

: "${VAULT:?VAULT is required}"
: "${FEAT:?FEAT is required}"

TODAY="${TODAY:-$(TZ=Asia/Tokyo date +%Y-%m-%d)}"
N="${DAILY_WINDOW_DAYS:-7}"
WINDOW_START=$(python3 -c "from datetime import date,timedelta;print((date.fromisoformat('$TODAY')-timedelta(days=$((N-1)))).isoformat())")

if [ -n "${HOST:-}" ]; then
  STATE_FILE="$VAULT/bin/last-${FEAT}-${HOST}.txt"
  if [ ! -f "$STATE_FILE" ] && [ -f "$VAULT/bin/last-${FEAT}.txt" ]; then
    STATE_FILE="$VAULT/bin/last-${FEAT}.txt"
  fi
else
  STATE_FILE="$VAULT/bin/last-${FEAT}.txt"
fi

LAST=$(grep -oE '^### [0-9]{4}-[0-9]{2}-[0-9]{2}' "$STATE_FILE" 2>/dev/null | head -1 | awk '{print $2}')

if ! [[ "${LAST:-}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  LAST=""
fi

if [ -z "$LAST" ] || [ "$LAST" \< "$WINDOW_START" ]; then
  PAST_START="$WINDOW_START"
elif [ "$LAST" \< "$TODAY" ]; then
  PAST_START=$(python3 -c "from datetime import date,timedelta;print((date.fromisoformat('$LAST')+timedelta(days=1)).isoformat())")
else
  PAST_START="$TODAY"
fi

d="$PAST_START"
while [ "$d" \< "$TODAY" ] || [ "$d" = "$TODAY" ]; do
  echo "$d"
  d=$(python3 -c "from datetime import date,timedelta;print((date.fromisoformat('$d')+timedelta(days=1)).isoformat())")
done