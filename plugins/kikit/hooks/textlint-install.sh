#!/usr/bin/env bash
# Installs textlint and the rules in textlint/package.json into the plugin data directory for work-technical-writing.
set -u

command -v pnpm >/dev/null 2>&1 || exit 0
[ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -n "${CLAUDE_PLUGIN_DATA:-}" ] || exit 0

src="$CLAUDE_PLUGIN_ROOT/textlint"
dest="$CLAUDE_PLUGIN_DATA/textlint"

if [ -x "$dest/node_modules/.bin/textlint" ] && cmp -s "$src/pnpm-lock.yaml" "$dest/pnpm-lock.yaml"; then
  exit 0
fi

mkdir -p "$dest" && cp "$src/package.json" "$src/pnpm-lock.yaml" "$dest/" || exit 0
if ! (cd "$dest" && pnpm install --frozen-lockfile --ignore-workspace >/dev/null 2>&1); then
  # The copied lockfile marks the install as done, so drop it to retry next session
  rm -f "$dest/pnpm-lock.yaml"
fi
exit 0
