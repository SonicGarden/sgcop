---
name: sgcop-setup
description: sgcop の RuboCop 設定を、導入先プロジェクトの .rubocop.yml にセットアップ・更新する。標準（rubocop.yml）か厳格版（rubocop_strict.yml）かの導入方針をまず確認して inherit_gem を整え、既存 .rubocop.yml から sgcop と重複する不要設定を削除する。gem 依存のカスタム Cop（enumerize 系など）は必要時のみ確認。そのうえで rubocop --auto-gen-config で .rubocop_todo.yml を生成し、違反（ノイズ）が多い Cop は無効化・Exclude・段階対応を提案、無効化したら todo を作り直す。
disable-model-invocation: true
license: MIT
---

# sgcop-setup

sgcop（SonicGarden 標準の RuboCop 設定・カスタム Cop を提供する Gem）を、**導入先の
Rails/Ruby プロジェクト**にセットアップするためのスキル。このスキルは sgcop gem 本体ではなく、
**sgcop を使う側のプロジェクト**で実行される。

## このスキルがやること / やらないこと

- **やる**:
  1. **導入方針（標準 / strict）を確認**して `inherit_gem` を整える。strict を選べば、汎用 Cop と
     カスタム Cop（`Sgcop/*`）がまとめて有効化される。
  2. 既存 `.rubocop.yml` から **sgcop と重複・冗長な設定を削除**する（承認のうえ）。
  3. **gem 依存のカスタム Cop**（`Sgcop/Enumerize*` など、strict でもコメントアウトのまま）は、
     対象 gem を使っているときだけ確認して有効化する。
  4. `rubocop --auto-gen-config` で **`.rubocop_todo.yml` を生成**し、実際の違反（ノイズ）量を見る。
  5. **ノイズが多い Cop だけ調整**を提案する（無効化 / `Exclude` / 段階対応 / `-a` 自動修正）。
     無効化・Exclude したら todo を作り直す。
- **やらない**: 個別 Cop を 1 つずつ机上で有効化確認することは**しない**（strict 一括＋実ノイズ確認に
  置き換えた）。ただし標準を選んだ場合のフォールバックとしてだけ、デフォルト無効カスタム Cop の
  1 つずつ確認を残す。すでにプロジェクトの `.rubocop.yml` に意図的に明示設定されている Cop
  （sgcop と異なる値の上書き）は尊重してスルーする。

なぜこの形か: sgcop の基本導入は `inherit_gem` 1 行で済み、判断が分かれる便利 Cop（カスタム +
実績ある推奨汎用）は **strict 設定が 1 ファイルにまとめている**。だから「1 つずつ確認」より
「方針を決めて strict を一括適用 → `--auto-gen-config` で実際のノイズを見て、多い Cop だけ調整」の
方が速く、判断も机上でなく実データに基づく。推奨 Cop のリストはスキルに持たず、**sgcop 本体の
strict 設定を唯一の出典**にする（保守の一元化）。

## 重要な前提

- Cop の一覧・趣旨・オプションは**導入先にインストール済みの sgcop gem から動的に取得する**。
  スキル内にハードコードした一覧は「参考値」にすぎない。sgcop に Cop が追加・変更されても
  動的取得なら自動追従でき、スキルが古びない。
- `config/default.yml` 内の Cop 名（YAML キー）を**そのまま**使う。特に RSpec 系は
  `Sgcop/Rspec/...`（`Rspec` 表記、README の `RSpec` とは違う）なので、必ず実ファイルの
  キーをコピーすること。`.rubocop.yml` のキーが gem 側と食い違うと設定が効かない。
- **対話の主役は「実ノイズを見ての調整」**（手順 6〜8）。Cop の有効化是非は strict 一括適用に委ね、
  ユーザーへの確認は「重複削除の承認」「gem 依存 Cop の有無」「ノイズが多い Cop の扱い」に絞る。

---

## 手順

### 1. プロジェクト種別を判定する

Rails か純 Ruby かを判定し、`inherit_gem` の参照先（標準 / strict）の候補を決める。実際にどちらを
書き込むかは手順 3 の方針確認で決まる。純 Ruby の場合はさらに RSpec を使っているかも判定する
（`Gemfile` の `rspec`/`rspec-core`、`spec/spec_helper.rb` の有無などで判定できる）。

- Rails 判定: `config/application.rb` の有無、`Gemfile` / `gemfile.lock` の `rails` 行、`bin/rails` など。
- 参照先の候補:
  - Rails → 標準 `rails/rubocop.yml` / strict `rails/rubocop_strict.yml`
    （RSpec 関連設定は内部で `ruby/rubocop_rspec.yml` を継承しているので追加指定は不要）
  - 純 Ruby（RSpec 不使用） → 標準 `ruby/rubocop.yml` / strict `ruby/rubocop_strict.yml`
  - 純 Ruby（RSpec 使用） → 標準 `[ruby/rubocop.yml, ruby/rubocop_rspec.yml]` /
    strict `[ruby/rubocop_strict.yml, ruby/rubocop_rspec_strict.yml]`（配列で複数ファイルを指定）

### 2. sgcop gem の導入を確認する

1. `Gemfile` に `sgcop` があるか確認する。なければ次を案内し、ユーザーに `bundle install` を促す:
   ```ruby
   gem 'sgcop', github: 'SonicGarden/sgcop', branch: 'main'
   ```
   （sgcop が入っていないと後段の動的取得ができないので、ここは先に解決する）
2. プロジェクトルートの `.rubocop.yml` の有無と中身を確認する。**ここでは書き込まない。**
   inherit_gem を実際に書くのは手順 3（方針確認後）。新規プロジェクト判定（`.rubocop.yml` が無い、
   または中身がほぼ空）かどうかを覚えておき、手順 3 の推奨に使う。

### 3. 導入方針（標準 / strict）を確認して inherit_gem を整える

sgcop には 2 段階の設定がある。これを最初に選んでもらう（これが最初の分岐点）:

- **標準** (`rubocop.yml`): SonicGarden 標準スタイル。デフォルト無効のカスタム Cop や推奨汎用 Cop は
  入らない。
- **strict** (`rubocop_strict.yml`): 標準に加え、**推奨汎用 Cop（`Layout/*`, `Style/*`, `Rails/*` の一部）と
  デフォルト無効カスタム Cop（`Sgcop/*`）をまとめて有効化**する。`inherit_gem` 1 行で全部入る。

1. **推奨の出し方を新規 / 既存で変える**:
   - **新規プロジェクト**（手順 2 で `.rubocop.yml` が無い／ほぼ空と判定）→ **strict を推奨**。最初から
     統一感を効かせられ、後から個別有効化する手間がない。
   - **既存プロジェクト** → **中立に二択**。判断材料として「strict は汎用 Cop + カスタム Cop をまとめて
     有効化するので、既存コードには違反が多く出やすい（ただし手順 6 の `--auto-gen-config` で段階導入
     できる）」を一言添える。
2. **AskUserQuestion** で「strict 一括 / 標準」を選ばせる。選んだ参照先:
   - Rails → strict `rails/rubocop_strict.yml` / 標準 `rails/rubocop.yml`
   - 純 Ruby（RSpec 不使用） → strict `ruby/rubocop_strict.yml` / 標準 `ruby/rubocop.yml`
   - 純 Ruby（RSpec 使用） → strict `[ruby/rubocop_strict.yml, ruby/rubocop_rspec_strict.yml]` /
     標準 `[ruby/rubocop.yml, ruby/rubocop_rspec.yml]`
3. 選んだ参照先で `.rubocop.yml` の `inherit_gem` を整える。何を書いたかを一言報告する:
   - 無ければ作成して `inherit_gem` を追加。
   - 既にあり sgcop を参照済みなら、参照先を選んだ方に合わせる（標準 ↔ strict の切替も含む）。
   - `inherit_gem` ブロックはあるが sgcop 参照が無ければ追記。

   ```yaml
   inherit_gem:
     sgcop: rails/rubocop_strict.yml   # 標準なら rails/rubocop.yml
   ```

   純 Ruby + RSpec の場合は配列で複数ファイルを指定する:

   ```yaml
   inherit_gem:
     sgcop:
       - ruby/rubocop_strict.yml
       - ruby/rubocop_rspec_strict.yml   # 標準なら ruby/rubocop.yml, ruby/rubocop_rspec.yml
   ```

### 4. 既存 .rubocop.yml から sgcop と重複する不要設定を削除する

既存プロジェクトでは、sgcop 導入前に書いた設定が `.rubocop.yml` に残り、sgcop 側と重複している
ことが多い。これを掃除する。

1. **sgcop 側の設定を動的取得する**。インストール済み sgcop gem の実体パスを取得し、選んだ設定
   ファイルが継承する全設定を読む:
   ```bash
   bundle show sgcop     # または: bundle info sgcop --path
   ```
   - strict を選んだ場合 → `rails/rubocop_strict.yml`（→ `rubocop.yml` → `../ruby/rubocop.yml`、
     さらに `../ruby/rubocop_strict.yml`, `../ruby/rubocop_rspec_strict.yml`）や、純 Ruby なら
     `ruby/rubocop_strict.yml`（+ RSpec 使用時は `ruby/rubocop_rspec_strict.yml`）の継承チェーンを辿る。
   - 標準を選んだ場合 → `rails/rubocop.yml`（→ `../ruby/rubocop.yml`, `../ruby/rubocop_rspec.yml`）等。
2. プロジェクトの `.rubocop.yml`（および自前で `inherit_from` している設定があればそれも）と突き合わせ、
   次を**重複・冗長**候補として洗い出す:
   - sgcop と**完全に同値**の設定（同じ Cop に同じオプション値）。
   - sgcop で**すでに有効化済みの Cop を `Enabled: true` で再宣言しているだけ**のもの。
3. **AskUserQuestion** で削除候補の一覧を提示し、承認を得てから削除する。
   - **意図的な上書き（sgcop と異なる値）は残す**。ユーザーが目的を持って変えている可能性が高い。
     消す前に「sgcop は X、プロジェクトは Y。これは意図的な上書きとみなして残す」と扱いを明示する。

### 5. プロジェクト状況で切り替える Cop を必要時のみ確認する

strict を選んだ場合、カスタム Cop（`Sgcop/*`）の大半は一括で有効化済み。ここで残るのは
**gem 依存で strict でもコメントアウトのままにしてある Cop** の判断だけ。

1. **gem 依存カスタム Cop**（主対象）:
   - `Sgcop/EnumerizeDefaultOption` / `Sgcop/EnumerizePredicatesOption` → `Gemfile` に `enumerize` が
     あるか軽くチェック。
     - あれば有効化を提案。`Sgcop/EnumerizePredicatesOption` は `AllowWithPrefix`（デフォルト `false`、
       `predicates: { prefix: true }` を許可したいなら `true`）も提示する。
     - 無ければスルー（提示自体しなくてよい）。
2. **標準（非 strict）を選んだ場合のフォールバック**: デフォルト無効カスタム Cop を 1 つずつ確認したい
   なら、ここで個別に提示する。各 Cop の趣旨・関連性・オプションの判断材料は
   [references/disabled-cops.md](references/disabled-cops.md) を使う。**strict を選んだ場合はこの
   1 つずつループはスキップ**（すでに一括有効化済みのため）。

有効化する場合、`.rubocop.yml` に追記するキーは gem 側 `config/default.yml` と完全一致させる
（特に `Sgcop/Rspec/...` 表記に注意）:

```yaml
Sgcop/EnumerizePredicatesOption:
  Enabled: true
  AllowWithPrefix: false
```

### 6. .rubocop_todo.yml を生成して実際のノイズを見る

ここからが**このスキルの主役**。机上で Cop の是非を聞くのではなく、実際にどれだけ違反が出るかを見る。

1. `bundle exec rubocop --auto-gen-config` を案内/実行する。これで `.rubocop_todo.yml` が生成され、
   `.rubocop.yml` の先頭に `inherit_from: .rubocop_todo.yml` が自動追記される（`inherit_gem` と共存する）。
   **実行できない場合**（ネットワーク遮断・gem 未解決などで `bundle install`/`rubocop` 自体が動かせない
   環境）は、無理に実行せず「未実行・未検証」と明示したうえで、想定される結果を参考情報として述べる
   にとどめる。実行不能を隠して確定的な件数を報告しない。
2. 生成後、**違反件数が多い Cop トップ N** を要約する（`.rubocop_todo.yml` の各 Cop の見出しコメントに
   `# Offense count: N` が入っている）。これが次の手順の調整対象。
3. 違反 0 件ならその旨を伝え、サマリ（手順 9）へ。

### 7. ノイズが多い Cop を調整提案する

`.rubocop_todo.yml` で違反件数が突出して多い Cop を抽出し、Cop ごとに **AskUserQuestion** で扱いを聞く。
判断材料（その Cop が何をチェックするか・なぜ違反が多いか）を 1 行添える。選択肢:

- **段階対応として todo に残す**（デフォルト）: 既存違反は `.rubocop_todo.yml` で許容し、新規コードだけ
  縛る。README「しつけ方」の標準的なやり方。
- **`rubocop -a` / `-A` で一括自動修正**: 自動修正に対応した Cop（`Layout/*`, `Style/HashSyntax` など多く）
  なら、無効化する前にまずこれを提示する。修正後は todo から消える。
- **`Exclude` で限定**: 特定ディレクトリ（`db/`, `spec/`, 生成コード等）だけ除外。
- **無効化**（`.rubocop.yml` で `Enabled: false`）: プロジェクト方針に合わない Cop のみ。

無効化・Exclude を選んだら、その設定を `.rubocop.yml` に追記する。

### 8. 無効化したら todo を再生成する

手順 7 で Cop を**無効化 / Exclude した場合**、その Cop の項目が `.rubocop_todo.yml` に残り続けて
紛らわしいので、`bundle exec rubocop --auto-gen-config` を再度案内し `.rubocop_todo.yml` を作り直す。
（自動修正や「todo に残す」だけを選んだ場合は再生成は不要。）

### 9. 完了サマリ

最後に次を一覧で報告する:
- 選んだ導入方針（標準 / strict）と `inherit_gem` の参照先
- 削除した重複・冗長設定
- 有効化した gem 依存カスタム Cop（とオプション）
- 無効化 / Exclude / 自動修正した Cop
- `.rubocop_todo.yml` に段階対応として残した違反の規模（件数や主な Cop）

そして、todo を段階的に潰していく運用（README「しつけ方」の方針）を案内する。

---

## 注意点・つまずきやすいところ

- **方針確認を最初に**: 標準か strict かで、後段（重複削除の対象範囲、カスタム Cop の扱い、ノイズ量）が
  すべて変わる。手順 3 を飛ばさない。
- **動的取得を必ず先に**: sgcop が未インストールだと `bundle show sgcop` が失敗する。手順 2 で導入を
  確実にしてから手順 4 以降に進む。動的取得できないときは references/disabled-cops.md をフォールバックに
  使い、その旨をユーザーに伝える。
- **Cop キーの表記**: `.rubocop.yml` に書くキーは gem 側 `config/default.yml` のキーと 1 文字単位で
  一致させる。食い違うと RuboCop が「未知の Cop」として無視する／警告を出す。
- **重複削除で意図的な上書きを消さない**: sgcop と異なる値の設定は、ユーザーが目的を持って上書きして
  いる可能性が高い。完全同値・再宣言だけを消し、値が違うものは残して扱いを明示する。
- **ノイズ調整は実データで**: 手順 7 の判断は `.rubocop_todo.yml` の `Offense count` に基づく。机上で
  「たぶん違反が多い」と推測せず、生成された todo の実数で話す。
- **無効化後の todo 再生成**: 無効化・Exclude した Cop が todo に残ると、潰すべき対象が水増しされて
  見える。手順 8 の再生成を忘れない。
- **出典は strict 設定**: 推奨汎用 Cop・カスタム Cop の一覧はスキルにハードコードせず、必ず sgcop 本体の
  設定ファイルを動的に読む。sgcop 側で Cop が追加・変更されても自動追従でき、二重管理を避けられる。
- **承認ゲートをまたいで編集をバッチ化しない**: 手順 3（inherit_gem）・手順 4（重複削除）・手順 7
  （ノイズ調整）はそれぞれ独立した承認ポイント。複数手順の変更を 1 回の編集にまとめると、後から
  一部だけ却下されたときに切り戻しが面倒になる。承認ごとに個別の編集を行う。
- **違反 0 件なら `.rubocop_todo.yml` は生成されない**: これは RuboCop 自体の挙動であり、空ファイルを
  手動で作る必要はない。手順 6 で 0 件と分かったら、ファイルの有無を気にせずそのままサマリに進む。
