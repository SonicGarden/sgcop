# Cop 修正ガイド

`.rubocop_todo.yml` の違反を Tier 順に潰すときの補助資料。SKILL.md 本体を肥大化させないため、
判断材料や具体的な書き方はここに切り出す。実行コマンド・コーディング規約・コミット記法は
**そのプロジェクトの流儀を優先**し、ここに書いた一般論で上書きしない。

## autocorrect 対応の見分け方

`.rubocop_todo.yml` の各 Cop には、`--auto-gen-config` が見出しコメントを付けている。ここで
その Cop が自動修正に対応しているか・安全かが分かる。

| 見出しコメント | 意味 | 対応 Tier |
|---|---|---|
| `# This cop supports safe autocorrecting (...).` | safe な自動修正に対応 | Tier 1（`-a`）で消える |
| `# This cop supports unsafe autocorrecting (...).` | 自動修正はあるが挙動が変わりうる | Tier 2（`-A`）。要テスト |
| （autocorrect の記載なし） | 自動修正なし | Tier 3（手動修正）のみ |

例（`.rubocop_todo.yml` の典型的な見出し）:

```yaml
# Offense count: 12
# This cop supports safe autocorrecting (--autocorrect).
Style/StringLiterals:
  ...
```

→ `# Offense count: 12` が違反件数、`safe autocorrecting` なので Tier 1 で潰せる、と読む。

## Tier 別の進め方

対象 Cop を todo から削除したあと（SKILL.md 手順 3）、その Cop に絞って実行するのが基本。
**`--only <Cop>` を付ける**と、まだ todo に残した他 Cop の出力が混ざらず進捗が見やすい。

**Tier の起点ルール**:

| todo コメント | 最高品質の Tier | 実際の進め方 |
|---|---|---|
| `safe autocorrecting` あり | Tier 1 | Tier 1 → 残りがあれば Tier 3（手動） |
| `unsafe autocorrecting` あり | Tier 2 | **Tier 1 から始める**（safe も一部当たる場合がある）→ 残りに Tier 2 → さらに残りがあれば Tier 3 |
| autocorrect 記載なし | Tier 3 のみ | Tier 1/2 はスキップして Tier 3（手動）に直行 |

「unsafe autocorrect 対応」でも Tier 1（`-a`）を最初に試すのは、一部の違反は safe で直せる場合があるため。
`rubocop_todo.yml` の `unsafe` 表記は「最高品質の Tier」を示すだけで、safe が使えないという意味ではない。

### Tier 1: safe autocorrect

```bash
bundle exec rubocop --only Style/StringLiterals -a
```

- `-a`（`--autocorrect`）は **safe な修正だけ** を当てる。挙動は変わらない前提なので、結果は
  基本的にそのまま信頼してよい。
- これで違反ゼロになれば、その Cop はこれで完了（SKILL.md 手順 6 の確認へ）。

### Tier 2: unsafe autocorrect

```bash
bundle exec rubocop --only Lint/SomeCop -A
```

- `-A`（`--autocorrect-all`）は **unsafe な修正も含めて** 当てる。コードの意味が変わる可能性がある。
- 当てる前にユーザーに一言断り、当てたあとは **必ずプロジェクトのテストを実行**して壊れていないか
  確認する（SKILL.md 手順 6）。
- 差分を目視して、意図しない書き換えが混ざっていないかも確認する。

### Tier 3: 手動修正

- autocorrect 非対応の Cop、または `-a` / `-A` を当てても残った違反は、1 件ずつ手で直す。
- `bundle exec rubocop --only <Cop>` で残った違反のファイル・行・メッセージを確認し、
  **意味を変えない範囲**でリファクタする。
- どう直すべきか分からない Cop は、メッセージ末尾の Cop 名（例 `Metrics/MethodLength`）で
  RuboCop 公式ドキュメントを引くと、目的と推奨される直し方が分かる。

## Exclude vs 無効化の使い分け

修正がアプリ仕様上不適切な違反だけ、`.rubocop.yml` で対応する（SKILL.md 手順 5）。範囲は狭い順に
選ぶ。

1. **特定ファイル/ディレクトリの `Exclude`**（第一候補）— 「この箇所だけは事情があって違反のまま
   にする」ケース。Cop 自体はプロジェクトに有効なまま残せる。

   ```yaml
   # 自動生成ファイルのため整形しない（手で直すと再生成で戻る）
   Style/SomeCop:
     Exclude:
       - 'db/schema.rb'
   ```

2. **Cop 全体の `Enabled: false`**（最後の手段）— その Cop の方針自体がプロジェクトに合わないと
   判断したときだけ。一部の箇所のためだけに全体を切らない。

   ```yaml
   # このプロジェクトの規約と方針が合わないため無効化
   Style/SomeCop:
     Enabled: false
   ```

### 理由コメントは必ず残す

`Exclude` も `Enabled: false` も、**なぜそうしたか**を1行コメントで添える（記法はプロジェクト規約に
従う）。「あえてチェックを外した」判断はコードにも差分にも現れにくく、理由が無いと後から対応漏れと
誤認されて蒸し返されたり、漫然と放置されたりする。判断の根拠を設定の隣に残しておくことが要。

判断が割れるもの（直せるのか無効化が妥当か迷うもの）は、勝手に決めずユーザーに相談してから倒す。
