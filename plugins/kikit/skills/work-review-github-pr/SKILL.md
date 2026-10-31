---
name: work-review-github-pr
description: "GitHub の PR をレビューするときに使う。「PR をレビューして」「この PR 見て」と頼まれたときに使う。バグ探しは /code-review に任せ、PR の目的の達成、スコープ、テスト、セキュリティを補う。確かめた指摘を GitHub の pending review（下書き）に付け、送るかどうかはユーザーが決める。"
---

# work-review-github-pr

`/code-review` が見ない観点を補って PR をレビューし、確かめた指摘を pending review に下書きする。pending review は本人にしか見えず、送るかどうかはユーザーが決める。テストやコードはローカルで実行せず、コードと CI の結果だけで確かめる。

## 手順

### 1. 材料を集める

PR 番号か URL を受け取る。なければ今のブランチの PR を使う。`gh pr view <PR> --json url` で PR の URL を確かめ、そこから `<owner>/<repo>` と `<number>` を決める。

- 本文、コミット、既存のレビュー: `gh pr view <PR> --json title,body,headRefOid,files,commits,closingIssuesReferences,reviews,comments`
- インラインのレビューコメント: `gh api repos/<owner>/<repo>/pulls/<number>/comments --paginate`
- 紐づく issue と、本文で参照している issue: `gh issue view`
- diff と CI の結果: `gh pr diff <PR>`、`gh pr checks <PR>`
- diff の外のコード: `git fetch https://github.com/<owner>/<repo>.git pull/<number>/head` のあと、`git show <headRefOid>:<path>` で読む。作業ツリーは切り替えない

ユーザーの pending review がすでにあると新しく作れない。`gh api repos/<owner>/<repo>/pulls/<number>/reviews --paginate --jq '.[] | select(.state == "PENDING")'` で確かめ、あれば止まって知らせる。

本文と issue から PR の目的を 1 文で言う。言えなければ、それ自体を指摘にする。

### 2. /code-review を呼ぶ

`/code-review medium --max-findings default <number>` を呼ぶ。level と `--max-findings` は、省くとユーザーが前回指定した値を引き継ぐので、必ず指定する。結果がバックグラウンドから届くときは、手順 3 を進めながら待つ。

### 3. 足りない観点を確かめる

- 目的: 本文や issue のゴールを diff が満たしているか
- スコープ: 本文と diff が食い違っていないか。関係のない変更が混ざっていないか
- テスト: 変更した振る舞いをテストが確かめているか。CI が失敗していれば、原因が PR にあるか
- セキュリティ: secret の混入、入力の検証、権限の確認

linter や formatter が見つけるものは指摘しない。

### 4. 指摘を分けて確かめる

`/code-review` と手順 3 の指摘のうち、同じものはまとめ、次の種類に分ける。種類と起こりやすさは、見積もれるだけのコードを読んで決める。起こりにくいものや、起きても影響の小さいものは、ここで捨てる。

| 種類 | 意味 |
|---|---|
| `must` | マージ前に直す必要がある |
| `want` | 直してほしいが、マージは止めない |
| `nits` | 小さな改善 |
| `ask` | 作者に意図や前提を聞きたい |

残った指摘は、head のコードや本文の具体的な箇所を根拠として示せるかを確かめる。根拠は、バグなら壊れる入力や状態、スコープなら本文と diff の食い違い、再利用なら置き換え先のコードになる。本文で意図が説明されているものや、既存のコメントや後のコミットで解消済みのものは捨てる。

- `must` と `want` は、根拠が見つかるまで呼び出し元や関連するコードを読む。読んでも確かめきれなければ、捨てずに `ask` へ回す
- `nits` は、根拠をすぐに示せなければ捨てる

### 5. 報告して、下書きに入れる指摘を決める

総評を 1〜2 行書き、指摘を重い順に並べる。各指摘には `file:line`、種類、根拠、直し方の案を付け、diff の外の行への指摘にはその旨を添える。捨てた指摘は件数だけ書く。そのうえで、下書きに入れる指摘をユーザーに確かめる。既定はすべてとする。

### 6. pending review を作る

[work-technical-writing](../work-technical-writing/SKILL.md) を読んでからコメントを書く。

- 1 コメントに 1 指摘を書き、次の型に沿う。種類は単独の行に置き、問題の文が折り返しても種類が埋もれないようにする
- 言語は PR の既存のやり取りに合わせ、メンションは書かない

````markdown
want:
<問題を 1 文で。何が、どの場合に困るか>

<根拠。バグなら壊れる入力や状態、スコープなら本文と diff の食い違い、再利用なら置き換え先のコード>

<直し方の案。数行で済むなら suggestion ブロックにする>
````

`ask` は、問題の代わりに質問を書き、根拠の代わりに、答えによって何が変わるかを書く。直し方の案は書かない。

review 全体の本文（`body`）は書かない。総評と diff の外の行への指摘は手順 5 で伝えてあり、送るときに本文へ書くかはユーザーが決める。

次の JSON をファイルに書き、`gh api repos/<owner>/<repo>/pulls/<number>/reviews --method POST --input <ファイル>` で作る。`event` を省くと pending review になる。

```json
{
  "commit_id": "<headRefOid>",
  "comments": [
    { "path": "<path>", "line": <line>, "side": "RIGHT", "body": "<コメント>" }
  ]
}
```

- `side` は、追加した行と変更のない行なら `RIGHT` にして head の行番号を使い、削除した行なら `LEFT` にして base の行番号を使う。複数行なら `start_line` と `start_side` を足す
- diff に含まれない行が 1 件でもあると、全体が 422 で失敗する。diff の外の行への指摘はコメントにしない

作ったら PR の URL を伝え、Files changed の画面で確かめて送るよう頼む。このスキルは review を送らない。
