---
name: sgcop-setup
description: sgcop の RuboCop 設定を、導入先プロジェクトの .rubocop.yml にセットアップ・更新する。inherit_gem の基本導入を整えたうえで、sgcop のデフォルト無効カスタム Cop（Sgcop/*）を 1 つずつ趣旨説明・推奨つきで確認しながら有効化する。ユーザーが明示的に呼び出したときのみ実行する。
---

# sgcop-setup

sgcop（SonicGarden 標準の RuboCop 設定・カスタム Cop を提供する Gem）を、**導入先の
Rails/Ruby プロジェクト**にセットアップするためのスキル。このスキルは sgcop gem 本体ではなく、
**sgcop を使う側のプロジェクト**で実行される。

## このスキルがやること / やらないこと

- **やる**: `inherit_gem` の基本導入を整える。そのうえで sgcop の**デフォルト無効**カスタム Cop
  （`Sgcop/*` のうち `Enabled: false` のもの）を 1 つずつ、趣旨と推奨を提示しながら確認して
  `.rubocop.yml` に追記していく。
- **やらない**: デフォルト有効の Cop は `inherit_gem` で自動的に効くので確認しない（基本スルー）。
  汎用 Cop（`Style/*`, `Rails/*` 等）は対象外。すでにプロジェクトの `.rubocop.yml` に明示設定
  されている Cop はスルーする。

なぜこの形か: sgcop の基本導入は `inherit_gem` 1 行で済む。判断が必要なのは「便利だが
プロジェクトの方針で入れるか分かれる」ためにデフォルト無効にされているカスタム Cop だけ。
そこにユーザーの確認を集中させる。

## 重要な前提

- Cop の一覧・趣旨・オプションは**導入先にインストール済みの sgcop gem から動的に取得する**。
  スキル内にハードコードした一覧は「参考値」にすぎない。sgcop に Cop が追加・変更されても
  動的取得なら自動追従でき、スキルが古びない。
- `config/default.yml` 内の Cop 名（YAML キー）を**そのまま**使う。特に RSpec 系は
  `Sgcop/Rspec/...`（`Rspec` 表記、README の `RSpec` とは違う）なので、必ず実ファイルの
  キーをコピーすること。`.rubocop.yml` のキーが gem 側と食い違うと設定が効かない。

---

## 手順

### 1. プロジェクト種別を判定する

Rails か純 Ruby かを判定し、`inherit_gem` の参照先を決める。

- Rails 判定: `config/application.rb` の有無、`Gemfile` / `gemfile.lock` の `rails` 行、`bin/rails` など。
- 参照先:
  - Rails → `sgcop: rails/rubocop.yml`
  - 純 Ruby → `sgcop: ruby/rubocop.yml`

### 2. sgcop gem の導入を確認し、inherit_gem を整える

1. `Gemfile` に `sgcop` があるか確認する。なければ次を案内し、ユーザーに `bundle install` を促す:
   ```ruby
   gem 'sgcop', github: 'SonicGarden/sgcop', branch: 'main'
   ```
   （sgcop が入っていないと後段の動的取得ができないので、ここは先に解決する）
2. プロジェクトルートの `.rubocop.yml` を確認する。
   - 無ければ作成し、`inherit_gem` を追加する。
   - 既にあり `inherit_gem` で sgcop を参照済みなら、そのままでよい。
   - `inherit_gem` はあるが sgcop 参照が無ければ、ブロックに追記する。

   ```yaml
   inherit_gem:
     sgcop: rails/rubocop.yml   # 純 Ruby なら ruby/rubocop.yml
   ```

**この基本導入行（inherit_gem）は確認なしで自動セットアップしてよい。** デフォルト有効 Cop と
同じく「sgcop を使うなら当然入れるもの」だから。ただし新規に `.rubocop.yml` を作る／既存を
書き換える場合は、何を書いたかを一言報告する。

### 3. デフォルト無効カスタム Cop を動的取得する

1. インストール済み sgcop gem の実体パスを取得する:
   ```bash
   bundle show sgcop     # または: bundle info sgcop --path
   ```
2. そのパスの `config/default.yml` を読み、以下を抽出する:
   - キーが `Sgcop/` で始まり、`Enabled: false` の Cop
   - 各 Cop の `Description`（趣旨説明に使う）
   - `Reference`（参考 URL があれば提示に添える）
   - `Enabled` 以外の設定可能オプションとそのデフォルト値
     （例: `EnforcedStyle` / `SupportedStyles` / `AllowWithPrefix` など）

参考までに、現時点でデフォルト無効なのは次の 11 個（**実行時の動的取得が正**。下表は目安）:

`Sgcop/NestedResourcesWithoutModule`, `Sgcop/NoAcceptsNestedAttributesFor`,
`Sgcop/StrictLoadingRequired`, `Sgcop/EnumerizeDefaultOption`,
`Sgcop/EnumerizePredicatesOption`, `Sgcop/ErrorMessageFormat`,
`Sgcop/Capybara/FragileSelector`, `Sgcop/Capybara/FillInArgument`,
`Sgcop/Rspec/ActionMailerTestHelper`, `Sgcop/Rspec/ActiveJobTestHelper`,
`Sgcop/Rspec/NoMethodCallInExpectation`

各 Cop の補足（なぜ無効か・どんなプロジェクト向きか・オプションの選び方）は
[references/disabled-cops.md](references/disabled-cops.md) を参照する。動的取得の Description が
薄いときや、オプションの推奨を判断するときに使う。

### 4. すでに設定済みの Cop を除外する

プロジェクトの `.rubocop.yml`（および自前で `inherit_from` している設定ファイルがあればそれも）を
読み、すでに明示設定されている `Sgcop/*` を洗い出す。動的取得したデフォルト無効 Cop から
**設定済みのものを除外**し、「未設定のデフォルト無効 Cop」だけを次のループの対象にする。

対象が 0 件なら、その旨を伝えてサマリ（手順 6）へ進む。

### 5. 1 つずつ確認するインタラクティブループ（このスキルの主役）

未設定のデフォルト無効 Cop を**1 つずつ**提示する。まとめて一覧で聞かず、Cop 単位で確認を取る。
各 Cop について、次を提示する:

1. **趣旨説明**: 何をチェックする Cop か、なぜデフォルト無効なのか（判断が分かれる理由）を
   簡潔に。`config/default.yml` の `Description` と references/disabled-cops.md を基にする。
2. **軽い関連性チェック**（任意・軽量。深掘りはしない）: その Cop が刺さる機能をプロジェクトが
   使っているかを軽く確認し、推奨に反映する。例:
   - `Sgcop/Capybara/*` → `spec/system` や `spec/features` の有無、Capybara 利用
   - `Sgcop/Enumerize*` → `Gemfile` に `enumerize` があるか
   - `Sgcop/Rspec/*` → `spec/` の有無・RSpec 利用
   - `Sgcop/StrictLoadingRequired` → ActiveRecord 利用（Rails なら基本該当）
   - `Sgcop/NoAcceptsNestedAttributesFor` → `accepts_nested_attributes_for` の既存利用数
3. **推奨**: 「有効化を推奨 / 現状維持を推奨」を理由つきで 1 行。関連機能を使っていないなら
   「現状維持でよい」と素直に言う。
4. **オプション設定の推奨**（オプションを持つ Cop のみ。重要）: `Enabled` 以外に設定値を持つ
   Cop は、単に `Enabled: true` にするだけでなく**どのオプション値にするか**まで推奨・確認する。
   - `Sgcop/Capybara/FillInArgument` → `EnforcedStyle`（`SupportedStyles: [label, name]`、
     デフォルト `label`）。既存 spec の `fill_in` の書き方を軽く見て、label / name どちらに
     統一するのが自然かを推奨する。
   - `Sgcop/EnumerizePredicatesOption` → `AllowWithPrefix`（デフォルト `false`。
     `predicates: { prefix: true }` を許可したいなら `true`）。
   - オプションを持たない Cop はこの提示を省略してよい。

そのうえで **AskUserQuestion** で確認する。選択肢は Cop の性質に応じて:
- オプションなし: 「有効化する（推奨）/ 現状維持」
- オプションあり: 「有効化する（推奨オプションで）/ 有効化する（別オプションで）/ 現状維持」

有効化が選ばれたら、プロジェクトの `.rubocop.yml` に追記する。キーは gem 側の `config/default.yml`
と完全一致させる（特に `Sgcop/Rspec/...` 表記に注意）:

```yaml
# オプションなし
Sgcop/StrictLoadingRequired:
  Enabled: true

# オプションあり
Sgcop/Capybara/FillInArgument:
  Enabled: true
  EnforcedStyle: label
```

ドキュメントリンクのコメント付与は任意（不要）。sgcop 本体の `add_doc_links.rb` は開発者向けで、
導入先では付けなくてよい。

### 6. 完了サマリ

最後に次を一覧で報告する:
- 今回有効化した Cop（とオプション）
- ユーザーが現状維持を選んだ Cop
- もともと設定済みでスキップした Cop

そして `bundle exec rubocop` の実行を促す。違反が大量に出る場合は、既存コードに対しては
`bundle exec rubocop --auto-gen-config` で `.rubocop_todo.yml` を生成し、段階的に潰していく
やり方を案内する（README「しつけ方」の方針）。

---

## 注意点・つまずきやすいところ

- **動的取得を必ず先に**: sgcop が未インストールだと `bundle show sgcop` が失敗する。手順 2 で
  導入を確実にしてから手順 3 に進む。動的取得できないときは references/disabled-cops.md の
  一覧をフォールバックに使い、その旨をユーザーに伝える。
- **Cop キーの表記**: `.rubocop.yml` に書くキーは gem 側 `config/default.yml` のキーと 1 文字
  単位で一致させる。食い違うと RuboCop が「未知の Cop」として無視する／警告を出す。
- **まとめて聞かない**: 「主役」は 1 つずつの確認体験。全 Cop を 1 回の質問に詰め込まない。
- **既存方針の尊重**: すでに `.rubocop.yml` で明示的に `Enabled: false` にしている Cop は、
  ユーザーが意図的に切っている可能性が高い。勝手に有効化せず、設定済みとしてスルーする。
