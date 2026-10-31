# kikit

どの作業にも効かせる原則と、特定の作業やツールの手順をまとめた skill 集。`kikit:principle-prove-it-works` のように `kikit:` を付けて呼ぶ。各 skill をいつ使い何をするかは、リンク先の SKILL.md に書いてある。

1 skill 1 責務とし、必要になったものだけを足す。層は名前の prefix で表す。

## principle: どの作業にも効かせる原則

- [principle-laziness-protocol](skills/principle-laziness-protocol/SKILL.md)
- [principle-prove-it-works](skills/principle-prove-it-works/SKILL.md)
- [principle-fix-root-causes](skills/principle-fix-root-causes/SKILL.md)
- [principle-sequence-verifiable-units](skills/principle-sequence-verifiable-units/SKILL.md)
- [principle-encode-lessons-in-structure](skills/principle-encode-lessons-in-structure/SKILL.md)
- [principle-build-the-lever](skills/principle-build-the-lever/SKILL.md)
- [principle-guard-the-context-window](skills/principle-guard-the-context-window/SKILL.md)

## meta: skill や CLAUDE.md、hook などの設定を直す

- [meta-reflect](skills/meta-reflect/SKILL.md)

## work: 特定の作業の手順

- [work-technical-writing](skills/work-technical-writing/SKILL.md)
- [work-no-comments](skills/work-no-comments/SKILL.md)
- [work-create-github-issue](skills/work-create-github-issue/SKILL.md)

## tool: 特定のツールの操作

この層の skill は手順の本文を持たず、呼ばれたときにツールが出力する手順を読み込む。ツールの版と手順がずれない代わりに、ツールがインストールされていないマシンでは呼び出しが失敗する。

- [tool-herdr](skills/tool-herdr/SKILL.md)
- [tool-hunk-review](skills/tool-hunk-review/SKILL.md)

## 出典

principle-*、meta-reflect、work-no-comments、work-technical-writing は [pstack](https://github.com/cursor/plugins/tree/main/pstack)（Lauren Tan、MIT、コミット `12d587df`）を翻訳・改変したもの。ライセンス全文は [LICENSE-pstack](LICENSE-pstack)。
