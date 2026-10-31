# kikit

どの作業にも効かせる原則と、特定の作業の手順をまとめた skill 集。skill は `kikit:principle-prove-it-works` のように `kikit:` を付けて呼ぶ。

1 skill 1 責務とし、必要になったものだけを足す。層は名前の prefix（`principle-`、`meta-`、`work-`）で表す。

## principle: どの作業にも効かせる原則

| skill | 使う場面 | すること |
|---|---|---|
| principle-laziness-protocol | 追加やリファクタの順番、diff の大きさを決めるとき | 先に消し、問題を解く最小の変更に寄せる |
| principle-prove-it-works | 完了と言う前 | 代理指標ではなく本物で確かめ、結果を示す |
| principle-fix-root-causes | デバッグするとき | 再現し、根本原因まで辿って直す |
| principle-sequence-verifiable-units | 複数ステップの作業や、コミットと PR の積み方を決めるとき | 確かめられる小さな単位に分け、1 つずつ確かめて進める |
| principle-encode-lessons-in-structure | 同じ指示や訂正が繰り返されたとき | lint・hook・スクリプトなどの仕組みで守らせる |
| principle-build-the-lever | 自明でない編集、移行、分析、チェック | 手作業の代わりに、作業をする・確かめる道具を作る |
| principle-guard-the-context-window | コンテキストや費用が膨らみそうなとき | 大量の出力はサブエージェントに回し、繰り返す実行は費用を先に見積もる |

## meta: skill や CLAUDE.md、hook などの設定を直す

| skill | 使う場面 | すること |
|---|---|---|
| meta-reflect | 振り返りを頼まれたときや、同じ訂正を 2 回受けたとき | セッションから学びを見つけ、仕組み・skill・CLAUDE.md への修正を提案する |

## work: 特定の作業の手順

| skill | 使う場面 | すること |
|---|---|---|
| work-technical-writing | 人が後から読む文章を書く・直すとき | 読み手が一度読めば判断や作業に移れる文書を、過不足のない量で書く |
| work-no-comments | コメントの整理を頼まれたときや、レビューに出す前 | コードをなぞるだけのコメントを、書いた本人とは別のサブエージェントの判定で取り除く |
| work-create-github-issue | GitHub issue を起票するとき | 着手する人に文脈を引き渡す issue を書き、合意を取ってから起票する |

## 出典

principle-*、meta-reflect、work-no-comments、work-technical-writing は [pstack](https://github.com/cursor/plugins/tree/main/pstack)（Lauren Tan、MIT、コミット `12d587df`）を翻訳・改変したもの。ライセンス全文は [LICENSE-pstack](LICENSE-pstack)。

work-technical-writing の `references/japanese-sentences.md` にある、読点、否定対比、箇条書きのラベルの規則は、[yomiyasu](https://github.com/nanaism/yomiyasu)（nanaism、MIT、v2.4.0）の推敲の規則を参考にしたもの。
