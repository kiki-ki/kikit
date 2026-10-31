# kikit

どの作業にも効かせる原則と、特定の作業やツールの手順をまとめた skill 集。`kikit:principle-prove-it-works` のように `kikit:` を付けて呼ぶ。各 skill をいつ使い何をするかは、リンク先の SKILL.md に書いてある。

1 skill 1 責務とし、必要になったものだけを足す。層は名前の prefix で表す。

## principle: どの作業にも効かせる原則

| skill | 概要 |
|---|---|
| [principle-laziness-protocol](skills/principle-laziness-protocol/SKILL.md) | 先に消し、最小の変更にする |
| [principle-prove-it-works](skills/principle-prove-it-works/SKILL.md) | 完了と言う前に本物で確かめる |
| [principle-fix-root-causes](skills/principle-fix-root-causes/SKILL.md) | 根本原因で直す |
| [principle-sequence-verifiable-units](skills/principle-sequence-verifiable-units/SKILL.md) | 確かめられる小さな単位で進める |
| [principle-encode-lessons-in-structure](skills/principle-encode-lessons-in-structure/SKILL.md) | 繰り返す指示を仕組みにする |
| [principle-build-the-lever](skills/principle-build-the-lever/SKILL.md) | 手作業の代わりに道具を作る |
| [principle-guard-the-context-window](skills/principle-guard-the-context-window/SKILL.md) | コンテキストと費用の膨らみを抑える |

## meta: エージェントの働き方を改善する

| skill | 概要 |
|---|---|
| [meta-reflect](skills/meta-reflect/SKILL.md) | セッションの学びを仕組みに残す |

## work: 特定の作業の手順

| skill | 概要 |
|---|---|
| [work-technical-writing](skills/work-technical-writing/SKILL.md) | 一度読めば分かる文章を書く |
| [work-no-comments](skills/work-no-comments/SKILL.md) | コードをなぞるだけのコメントを取り除く |
| [work-create-github-issue](skills/work-create-github-issue/SKILL.md) | 着手できる GitHub issue を起票する |

## tool: 特定のツールの操作

この層の skill は手順の本文を持たず、呼ばれたときにツールが出力する手順を読み込む。ツールの版と手順がずれない代わりに、ツールがインストールされていないマシンでは呼び出しが失敗する。

| skill | 概要 |
|---|---|
| [tool-herdr](skills/tool-herdr/SKILL.md) | Herdr を操作する |
| [tool-hunk-review](skills/tool-hunk-review/SKILL.md) | Hunk のセッションで差分をレビューする |

## hook

[technical-writing-gate.sh](hooks/technical-writing-gate.sh) は、`kikit:work-technical-writing` を呼ぶまで次の操作を止める。

- `.md` への Write と Edit。`/tmp`、`/private/tmp`、Claude Code の memory の下は止めない
- `gh pr` と `gh issue` の `create`、`edit`、`comment`、`review`

呼んだ記録はセッションと subagent ごとに持ち、コンパクトと `/clear` で消える。jq を使うので、jq がないマシンでは何も止めない。

## textlint

work-technical-writing は、`textlint` コマンドが使えるときだけ、書いた文章を [textlintrc.json](textlint/textlintrc.json) で検査する。使うには、textlint と次のルールを 1 つの `node_modules` にまとめて入れ、`textlint` を PATH に置く。パッケージごとに別々にグローバルへ入れると、textlint からルールが見えない。版は [package.json](../../package.json) に合わせる。

- `textlint`
- `textlint-filter-rule-allowlist`
- `textlint-rule-preset-ja-technical-writing`
- `@textlint-ja/textlint-rule-preset-ai-writing`
- `textlint-rule-preset-ja-spacing`
- `textlint-rule-ja-hiragana-keishikimeishi`
- `textlint-rule-ja-hiragana-hojodoushi`

## 出典

principle-*、meta-reflect、work-no-comments、work-technical-writing は [pstack](https://github.com/cursor/plugins/tree/main/pstack)（Lauren Tan、MIT、コミット `12d587df`）を翻訳・改変したもの。ライセンス全文は [LICENSE-pstack](LICENSE-pstack)。
