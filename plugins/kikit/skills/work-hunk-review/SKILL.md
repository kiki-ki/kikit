---
name: work-hunk-review
description: "Hunk の差分レビューのセッションを CLI で操作するときに使う。Hunk のセッションが起動しているときや、差分を対話的にレビューしたいと言われたときに使う。インストールされた hunk に同梱の hunk-review の手順を読み込み、ファイル・hunk・行の移動、セッションの再読み込み、インラインのレビューコメント、文字範囲の強調をする。"
allowed-tools: Bash(sh ${CLAUDE_PLUGIN_ROOT}/skills/work-hunk-review/scripts/show-skill.sh)
---

# work-hunk-review

インストールされた hunk の版に合った手順を、`hunk skill path` が指すファイルから読み込む。以下がその中身で、これに従う。

!`sh ${CLAUDE_PLUGIN_ROOT}/skills/work-hunk-review/scripts/show-skill.sh`
