#!/usr/bin/env bash
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
CLAUDE_PLUGIN_ROOT="$root/plugins/kikit" CLAUDE_PLUGIN_DATA="$root/.cache" bash "$root/plugins/kikit/hooks/textlint-install.sh"
"$root/.cache/textlint/node_modules/.bin/textlint" --config "$root/plugins/kikit/textlint/textlintrc.json" "**/*.md"
