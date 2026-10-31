#!/usr/bin/env bash
# Usage: technical-writing-gate.sh record|reset|check [gh command], with the hook input JSON on stdin.
set -u

# Fail open: this hook nudges writing, and blocking all writes on a machine without jq would be worse
command -v jq >/dev/null 2>&1 || exit 0

session_id='' agent_id='' skill='' file_path=''
eval "$(jq -r '@sh "session_id=\(.session_id // "") agent_id=\(.agent_id // "") skill=\(.tool_input.skill // .command_name // "") file_path=\(.tool_input.file_path // "")"')"
[ -n "$session_id" ] || exit 0
state_dir="$CLAUDE_PLUGIN_DATA/technical-writing"
# Subagents share the parent's session_id, so key by agent_id too or they would pass on the parent's call
marker="$state_dir/$session_id.$agent_id"

case "${1:-}" in
  record)
    if [[ "$skill" =~ (^|:)work-technical-writing$ ]]; then
      mkdir -p "$state_dir" && touch "$marker"
    fi
    ;;
  reset)
    rm -f "$state_dir/$session_id".*
    find "$state_dir" -type f -mtime +7 -delete 2>/dev/null
    ;;
  check)
    [ -e "$marker" ] && exit 0
    # hooks.json passes the gh command it matched with `if`; Write and Edit pass nothing
    target=${2:-}
    if [ -z "$target" ]; then
      case "$file_path" in
        *.md | *.MD) ;;
        *) exit 0 ;;
      esac
      case "$file_path" in
        /tmp/* | /private/tmp/* | */.claude/projects/*/memory/*) exit 0 ;;
      esac
      target=$file_path
    fi
    echo "${target} の前に、Skill ツールで kikit:work-technical-writing を読み込んでから書き直してください。人が読む文章はこの skill に沿って書きます。" >&2
    exit 2
    ;;
esac
exit 0
