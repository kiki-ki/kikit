---
name: work-review-github-pr
description: "GitHub の PR をレビューするときに使う。「PR をレビューして」「この PR 見て」と頼まれたときに使う。バグ探しは /code-review に任せ、PR の目的の達成、スコープ、テスト、セキュリティを補って確かめる。妥当だと確かめた指摘だけを、GitHub の pending review（下書き）にコメントとして付ける。送るかどうかはユーザーが決める。"
---

# work-review-github-pr

`/code-review` が見ない観点を補って PR をレビューし、確かめた指摘だけを pending review に下書きする。pending review は本人にしか見えないので、中身を確かめて送るのはユーザーに任せる。

テストやコードをローカルで実行しない。コードを読むことと CI の結果だけで確かめる。

## 手順

### 1. 材料を集める

PR 番号か URL を受け取る。なければ、今のブランチの PR を使う。`gh pr view <PR> --json url` で URL を確かめ、URL の `<owner>/<repo>` と `<number>` を以降のコマンドで使う。PR のリポジトリは、作業ディレクトリの origin と同じとは限らない（fork を origin にしている場合など）。

- 同じ PR にユーザーの pending review がすでにあると、GitHub は新しく作れない。あれば止まってユーザーに知らせる。`gh api repos/<owner>/<repo>/pulls/<number>/reviews --paginate --jq '.[] | select(.state == "PENDING")'` で確かめる。
- 本文、紐づく issue、既存のレビューを読む。`gh pr view <PR> --json title,body,baseRefName,headRefOid,files,commits,closingIssuesReferences,reviews,comments` を使う。
- 既存のインラインのレビューコメントを、`gh api repos/<owner>/<repo>/pulls/<number>/comments --paginate` で読む。`gh pr view` では取れない。
- `gh pr diff <PR>` で diff を読む。
- `gh pr checks <PR>` で CI の結果を見る。
- diff の外のコードは、`git fetch https://github.com/<owner>/<repo>.git pull/<number>/head` で head を取ってきてから読む。`git show <headRefOid>:<path>` や `git grep <pattern> <headRefOid>` を使い、作業ツリーは切り替えない。

本文と issue から、PR の目的を 1 文で言えるようにする。言えなければ、それ自体を指摘にする。

### 2. バグ探しを /code-review に任せる

`/code-review high <number>` を呼び、正しさのバグと、再利用・簡素化の指摘を受け取る。level を省くと、ユーザーが最後に打った level（`max` や `ultra` を含む）を引き継ぐので、必ず指定する。ユーザーが別の level を頼んだときだけ、それに替える。投稿は手順 6 でまとめて行うので、`--comment` と `--fix` は付けない。

`/code-review` はバックグラウンドで動くことがある。その場合は手順 3 を進めながら結果の通知を待ち、届いてから手順 4 に進む。

### 3. 足りない観点を確かめる

`/code-review` が見ない次の観点を、自分で確かめる。

- 目的の達成: 本文や issue のゴールを diff が満たしているか。
- スコープ: 本文にあって diff にない変更や、diff にあって本文にない変更（関係のない変更の混入）がないか。
- テスト: テストが、変更した振る舞いを確かめているか。CI が失敗していれば、原因が PR の変更にあるかを確かめる。
- セキュリティ: secret の混入、外部からの入力の検証、権限の確認が抜けていないか。

linter や formatter が見つけるスタイルの違反は指摘しない。

### 4. 指摘の妥当性を確かめる

`/code-review` の指摘と手順 3 の指摘を、1 件ずつ確かめる。`/code-review` は level によって、候補を検証せずに返す。同じ問題を指す指摘は 1 件にまとめる。

- head のコードと呼び出し元を読み、指摘どおりに壊れる具体的な入力や状態を言えるか。
- 本文やコミットで、意図した変更だと説明されていないか。
- 既存のレビューコメントや後のコミットで、すでに指摘・解消されていないか。

壊れる入力や状態を言えない指摘は捨てる。読むだけでは確かめきれないが、作者に聞く価値があるものは `question` にする。

確かめた指摘を次の 4 種類に分ける。

- `must`: マージ前に直す必要がある。
- `should`: 直したほうがよいが、マージは止めない。
- `nit`: 好みに近い小さな改善。
- `question`: 作者に意図や前提を確かめたい。

### 5. 報告して、下書きに入れる指摘を決める

会話で報告する。総評を 1〜2 行書き、指摘を重い順に並べる。各指摘には `file:line`、種類、根拠、直し方の案を付ける。手順 4 で捨てた指摘は、件数と主な理由だけを書く。

そのうえで、下書きに入れる指摘をユーザーに確かめる。既定はすべてとし、外したいものを指定してもらう。

### 6. pending review を作る

[work-technical-writing](../work-technical-writing/SKILL.md) を読んでから、コメントを書く。

- 1 コメントに 1 指摘を書く。先頭に `must:` のように種類を付け、問題 → 根拠（壊れる入力や状態）→ 直し方の案の順に書く。
- 数行で済む修正は、`suggestion` ブロックで示す。
- 言語は、PR の本文と既存のやり取りに合わせる。
- ユーザーや team をメンションしない。ハンドル名を書くときはバッククォートで囲む。

次の JSON をファイルに書き、`gh api repos/<owner>/<repo>/pulls/<number>/reviews --method POST --input <ファイル>` で作る。`event` を指定しないと pending review になる。

```json
{
  "commit_id": "<headRefOid>",
  "body": "<総評と、diff の外の行への指摘>",
  "comments": [
    { "path": "<path>", "line": 42, "side": "RIGHT", "body": "<コメント>" }
  ]
}
```

- `line` は、追加した行と変更のない行なら head の行番号で、`side` は `RIGHT` にする。削除した行なら base の行番号で、`side` は `LEFT` にする。
- インラインコメントを付けられるのは diff に含まれる行だけで、それ以外の行が 1 件でもあると、review 全体の作成が 422 で失敗する。diff の外の行への指摘は `body` に `file:line` を添えて書く。
- 複数行に付けるときは、`start_line` と `start_side` を足す。

作ったら、PR の URL と、Files changed の画面で下書きを確かめて送ってほしいことをユーザーに伝える。このスキルは、Approve、Request changes、Comment のどれも送らない。
