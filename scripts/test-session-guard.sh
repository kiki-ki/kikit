#!/usr/bin/env bash
set -euo pipefail

guard="$(cd "$(dirname "$0")/.." && pwd)/plugins/kikit/hooks/session-guard.sh"
tmp=$(mktemp -d)
sleeper=""
cleanup() {
  [[ -z "$sleeper" ]] || kill "$sleeper" 2>/dev/null || true
  rm -rf "$tmp"
}
trap cleanup EXIT

git init -q "$tmp/repo"
git -C "$tmp/repo" -c core.hooksPath=/dev/null commit -q --allow-empty -m init
git -C "$tmp/repo" worktree add -q "$tmp/wt"
mkdir "$tmp/plain"
repo=$(cd "$tmp/repo" && pwd -P)
wt=$(cd "$tmp/wt" && pwd -P)
registry="$repo/.git/kikit-sessions"

failures=0
run() { printf '{"hook_event_name":"%s","session_id":"%s","cwd":"%s"%s}' "$1" "$2" "$3" "${4:-}" | bash "$guard"; }
expect() {
  local name=$1 pattern=$2 output=$3
  if [[ -z "$pattern" && -z "$output" ]] || [[ -n "$pattern" && "$output" == *"$pattern"* ]]; then
    echo "ok: $name"
  else
    echo "FAIL: $name: got [$output]"
    failures=$((failures + 1))
  fi
}
register_sleeper() {
  printf '%s\t%s\t%s\n' "$sleeper" "$(ps -o lstart= -p "$sleeper")" "$2" >"$registry/$1"
}

expect "alone" "" "$(run SessionStart s1 "$repo")"

sleep 300 &
sleeper=$!
register_sleeper s2 "$repo"
expect "live session in the same worktree" "PID $sleeper" "$(run SessionStart s1 "$repo")"
expect "same worktree from a subdirectory" "PID $sleeper" "$(mkdir -p "$repo/sub" && run SessionStart s1 "$repo/sub")"

register_sleeper s3 "$wt"
rm "$registry/s2"
expect "live session in another worktree" "" "$(run SessionStart s1 "$repo")"

kill "$sleeper"
wait "$sleeper" 2>/dev/null || true
register_sleeper s2 "$repo" 2>/dev/null || printf '%s\t%s\t%s\n' "$sleeper" "gone" "$repo" >"$registry/s2"
expect "dead session" "" "$(run SessionStart s1 "$repo")"
expect "dead session entry removed" "" "$(ls "$registry" | grep -v '^s1$' || true)"

expect "outside git" "" "$(run SessionStart s1 "$tmp/plain")"

run SessionEnd s1 "$repo"
expect "entry removed on SessionEnd" "" "$(ls "$registry" | grep '^s1$' || true)"

run SessionStart s4 "$repo" >/dev/null
expect "this session is not counted again on resume" "" "$(run SessionStart s4 "$repo")"
expect "another session before the move" "PID" "$(run SessionStart s5 "$repo")"
expect "session moved into its own worktree" "" "$(run CwdChanged s4 "$wt" ",\"new_cwd\":\"$wt\"" && run SessionStart s5 "$repo")"

((failures == 0))
