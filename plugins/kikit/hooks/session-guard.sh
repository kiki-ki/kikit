#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

command -v jq >/dev/null || exit 0

input=$(cat)
event=$(jq -r '.hook_event_name // empty' <<<"$input")
session=$(jq -r '.session_id // empty' <<<"$input")
cwd=$(jq -r '.new_cwd // .cwd // empty' <<<"$input")
[[ -n "$session" && -d "$cwd" ]] || exit 0

common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || exit 0
top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null) || exit 0
registry="$common/kikit-sessions"

if [[ "$event" == "SessionEnd" ]]; then
  rm -f "$registry/$session"
  exit 0
fi

# Hooks may run under a wrapper shell, so the session's Claude process is the nearest non-shell ancestor.
pid=$PPID
while [[ "$(basename -- "$(ps -o comm= -p "$pid" 2>/dev/null)")" =~ ^-?(sh|bash|zsh|dash)$ ]]; do
  pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
done
started() { ps -o lstart= -p "$1" 2>/dev/null; }

mkdir -p "$registry"
printf '%s\t%s\t%s\n' "$pid" "$(started "$pid")" "$top" >"$registry/$session"

[[ "$event" == "SessionStart" ]] || exit 0

others=()
for entry in "$registry"/*; do
  [[ "$(basename -- "$entry")" != "$session" ]] || continue
  IFS=$'\t' read -r other_pid other_start other_top <"$entry" || continue
  # Matching the start time keeps a reused PID from counting as the old session.
  if [[ "$other_pid" =~ ^[0-9]+$ ]] && [[ "$(started "$other_pid")" == "$other_start" ]]; then
    [[ "$other_top" != "$top" ]] || others+=("$other_pid")
  else
    rm -f "$entry"
  fi
done

((${#others[@]} > 0)) || exit 0

message="このワークツリー（${top}）では、別の Claude Code セッション（PID ${others[*]}）も動いている。ファイルの編集や、git の commit・switch・stash をする前に、EnterWorktree で専用のワークツリーに移る。読むだけなら移らなくてよい。"
jq -n --arg m "$message" '{
  systemMessage: $m,
  hookSpecificOutput: { hookEventName: "SessionStart", additionalContext: $m }
}'
