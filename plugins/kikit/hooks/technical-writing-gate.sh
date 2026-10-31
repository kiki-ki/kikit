#!/usr/bin/env bash
# Usage: technical-writing-gate.sh record|reset|check, with the hook input JSON on stdin.
set -u

# Fail open: this hook nudges writing, and blocking all writes on a machine without jq would be worse
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
field() { jq -r "$1 // empty" <<<"$input"; }

session_id=$(field .session_id)
[ -n "$session_id" ] || exit 0
state_dir="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/kikit}/technical-writing"
# Subagents share the parent's session_id, so key by agent_id too or they would pass on the parent's call
marker="$state_dir/$session_id.$(field .agent_id)"

case "${1:-}" in
  record)
    skill=$(field '.tool_input.skill // .command_name')
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
    case "$(field .tool_name)" in
      Write | Edit)
        target=$(field .tool_input.file_path)
        case "$target" in
          *.md | *.MD) ;;
          *) exit 0 ;;
        esac
        case "$target" in
          /tmp/* | /private/tmp/* | */.claude/projects/*/memory/*) exit 0 ;;
        esac
        ;;
      Bash)
        target=$(field .tool_input.command)
        [[ "$target" =~ (^|[^[:alnum:]_-])gh[[:space:]]+(pr|issue)[[:space:]]+(create|edit|comment|review)([[:space:]]|$) ]] || exit 0
        target="gh ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
        ;;
      *) exit 0 ;;
    esac
    echo "${target} の前に、Skill ツールで kikit:work-technical-writing を読み込んでから書き直してください。人が読む文章はこの skill に沿って書きます。" >&2
    exit 2
    ;;
esac
exit 0
