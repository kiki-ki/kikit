#!/usr/bin/env bash
set -u

gate="$(dirname "$0")/technical-writing-gate.sh"
CLAUDE_PLUGIN_DATA=$(mktemp -d)
export CLAUDE_PLUGIN_DATA
trap 'rm -rf "$CLAUDE_PLUGIN_DATA"' EXIT
failures=0

run() {
  bash "$gate" "$1" <<<"$2" 2>/dev/null
}

expect() {
  local want=$1 name=$2 mode=$3 json=$4 got
  run "$mode" "$json"
  got=$?
  if [ "$got" -ne "$want" ]; then
    echo "FAIL: $name (exit $got, want $want)" >&2
    failures=$((failures + 1))
  fi
}

edit() { printf '{"session_id":"s1","tool_name":"Edit","tool_input":{"file_path":"%s"}%s}' "$1" "${2:-}"; }
bash_cmd() { jq -cn --arg c "$1" '{session_id:"s1",tool_name:"Bash",tool_input:{command:$c}}'; }

expect 2 "edit README.md" check "$(edit /repo/README.md)"
expect 2 "write SKILL.md" check '{"session_id":"s1","tool_name":"Write","tool_input":{"file_path":"/repo/skills/x/SKILL.md"}}'
expect 0 "edit code" check "$(edit /repo/main.go)"
expect 0 "edit under /tmp" check "$(edit /tmp/notes.md)"
expect 0 "edit under /private/tmp" check "$(edit /private/tmp/x/notes.md)"
expect 0 "edit memory" check "$(edit /Users/u/.claude/projects/p/memory/MEMORY.md)"
expect 2 "gh pr create" check "$(bash_cmd 'gh pr create --draft --title t --body b')"
expect 2 "gh issue comment after cd" check "$(bash_cmd 'cd repo && gh issue comment 1 --body b')"
expect 0 "gh pr view" check "$(bash_cmd 'gh pr view 1')"
expect 0 "git commit" check "$(bash_cmd 'git commit -m "docs: update README.md"')"
expect 0 "not a gh command" check "$(bash_cmd 'echo ngh pr create')"
expect 0 "other tool" check '{"session_id":"s1","tool_name":"Read","tool_input":{"file_path":"/repo/README.md"}}'
expect 0 "no session id" check '{"tool_name":"Edit","tool_input":{"file_path":"/repo/README.md"}}'

expect 0 "record another skill" record '{"session_id":"s1","tool_name":"Skill","tool_input":{"skill":"kikit:work-no-comments"}}'
expect 2 "still blocked after another skill" check "$(edit /repo/README.md)"
expect 0 "record via Skill tool" record '{"session_id":"s1","tool_name":"Skill","tool_input":{"skill":"kikit:work-technical-writing"}}'
expect 0 "allowed after the skill" check "$(edit /repo/README.md)"
expect 2 "subagent is not covered by the parent" check "$(edit /repo/README.md ',"agent_id":"a1"')"
expect 0 "record in subagent" record '{"session_id":"s1","agent_id":"a1","tool_name":"Skill","tool_input":{"skill":"kikit:work-technical-writing"}}'
expect 0 "subagent allowed after its own call" check "$(edit /repo/README.md ',"agent_id":"a1"')"
expect 0 "reset on compact" reset '{"session_id":"s1","source":"compact"}'
expect 2 "blocked again after compact" check "$(edit /repo/README.md)"
expect 2 "subagent blocked again after compact" check "$(edit /repo/README.md ',"agent_id":"a1"')"
expect 0 "record via slash command" record '{"session_id":"s1","command_name":"kikit:work-technical-writing","expansion_type":"slash_command"}'
expect 0 "allowed after slash command" check "$(edit /repo/README.md)"
expect 2 "other session still blocked" check '{"session_id":"s2","tool_name":"Edit","tool_input":{"file_path":"/repo/README.md"}}'

if [ "$failures" -gt 0 ]; then
  echo "$failures failure(s)" >&2
  exit 1
fi
echo "all technical-writing-gate cases passed"
