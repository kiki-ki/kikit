# kikit

どの作業にも当てはまる原則と、特定の作業やツールの手順をまとめた skill 集。`kikit:principle-prove-it-works` のように `kikit:` を付けて呼ぶ。各 skill をいつ使い何をするかは、リンク先の SKILL.md に書いてある。

1 skill 1 責務とし、必要になったものだけを足す。層は名前の prefix で表す。

## principle: どの作業にも当てはまる原則

この層の skill はモデルからは自動で呼ばれない。SessionStart の hook（[hooks/router.sh](hooks/router.sh)）が、各 SKILL.md の description とパスの一覧を [hooks/router.md](hooks/router.md) の前置きと合わせて差し込み、モデルは条件に当たった原則の SKILL.md を Read で読む。description から自動で呼ばせるより確実に読まれるためだ。

- [principle-laziness-protocol](skills/principle-laziness-protocol/SKILL.md): 先に消し、最小の変更にする
- [principle-prove-it-works](skills/principle-prove-it-works/SKILL.md): 完了と言う前に本物で確かめる
- [principle-fix-root-causes](skills/principle-fix-root-causes/SKILL.md): 根本原因で直す
- [principle-sequence-verifiable-units](skills/principle-sequence-verifiable-units/SKILL.md): 確かめられる小さな単位で進める
- [principle-encode-lessons-in-structure](skills/principle-encode-lessons-in-structure/SKILL.md): 繰り返す指示を仕組みにする
- [principle-build-the-lever](skills/principle-build-the-lever/SKILL.md): 手作業の代わりに道具を作る
- [principle-guard-the-context-window](skills/principle-guard-the-context-window/SKILL.md): コンテキストと費用の膨らみを抑える

## meta: エージェントの働き方を改善する

- [meta-reflect](skills/meta-reflect/SKILL.md): セッションの学びを仕組みに残す

## work: 特定の作業の手順

- [work-technical-writing](skills/work-technical-writing/SKILL.md): 一度読めば分かる文章を書く
- [work-no-comments](skills/work-no-comments/SKILL.md): コードをなぞるだけのコメントを取り除く
- [work-create-github-issue](skills/work-create-github-issue/SKILL.md): 着手できる GitHub issue を起票する
- [work-review-github-pr](skills/work-review-github-pr/SKILL.md): GitHub の PR をレビューし、指摘を下書きする

## tool: 特定のツールの操作

この層の skill は手順の本文を持たず、呼ばれたときにツールが出力する手順を読み込む。ツールの版と手順がずれない代わりに、ツールがインストールされていないマシンでは呼び出しが失敗する。

- [tool-herdr](skills/tool-herdr/SKILL.md): Herdr を操作する
- [tool-hunk-review](skills/tool-hunk-review/SKILL.md): Hunk のセッションで差分をレビューする

## 出典

principle-*、meta-reflect、work-no-comments、work-technical-writing は [pstack](https://github.com/cursor/plugins/tree/main/pstack)（Lauren Tan、MIT、コミット `12d587df`）を翻訳・改変したもの。ライセンス全文は [LICENSE-pstack](LICENSE-pstack)。
