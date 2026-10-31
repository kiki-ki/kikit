#!/usr/bin/env bash
set -euo pipefail

root="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

cat "$root/hooks/router.md"
echo

for skill in "$root"/skills/principle-*/SKILL.md; do
  awk -v path="$skill" '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { exit }
    in_fm && sub(/^name: */, "") { name = $0 }
    in_fm && sub(/^description: */, "") { gsub(/^"|"$/, ""); desc = $0 }
    END { printf "- %s: %s\n  %s\n", name, desc, path }
  ' "$skill"
done
