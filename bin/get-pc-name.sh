#!/usr/bin/env bash
raw="${SECOND_BRAIN_PC_NAME:-$(hostname -s 2>/dev/null || echo "default")}"
sanitized=$(printf '%s' "$raw" | LC_ALL=C tr -cs 'A-Za-z0-9_-' '-' | sed 's/-\+/-/g; s/^-//; s/-$//')
printf '%s\n' "${sanitized:-default}"