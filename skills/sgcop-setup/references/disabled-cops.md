# デフォルト無効カスタム Cop の補足

sgcop の `config/default.yml` で `Enabled: false` になっているカスタム Cop の補足資料。
**正は常に導入先 gem の `config/default.yml`（動的取得）**。この表は、Description だけでは
趣旨や「どんなプロジェクトに向くか」「オプションの選び方」が伝わりにくいときの補完。
gem が新しくなって内容が食い違ったら、動的取得側を優先すること。

各 Cop のキーは `config/default.yml` の表記をそのまま使う（特に RSpec 系は `Sgcop/Rspec/...`）。

---

## Rails / ルーティング系

### `Sgcop/NestedResourcesWithoutModule`
- **趣旨**: ネストした `resources` ルーティングには `module:` オプションを使おう。
- **なぜ無効**: ネスト構造やコントローラ配置の方針はプロジェクトごとに異なるため。
- **向くプロジェクト**: ネストルートが多く、コントローラを名前空間で整理する方針のチーム。
- **関連性チェック**: `config/routes.rb` にネストした `resources` があるか。
- **オプション**: なし。

### `Sgcop/NoAcceptsNestedAttributesFor`
- **趣旨**: `accepts_nested_attributes_for` を避け、Form Object の利用を検討しよう
  （DHH もこの機能を削除したがっている）。
- **なぜ無効**: 既存プロジェクトで多用されていると一気に違反が出る。設計方針の転換を伴う。
- **向くプロジェクト**: 新規／Form Object パターンを採用しているチーム。
- **関連性チェック**: `app/models/**/*.rb` の `accepts_nested_attributes_for` 利用数。多い場合は
  「導入すると違反多数。段階対応前提なら有効化、そうでなければ現状維持」と伝える。
- **オプション**: なし。

### `Sgcop/StrictLoadingRequired`
- **趣旨**: `includes` / `preload` して変数代入する場合は `strict_loading` を付け、仕組みで
  N+1 を防ごう。
- **なぜ無効**: `strict_loading` の運用方針が固まっていないプロジェクトもあるため。
- **向くプロジェクト**: N+1 を厳格に防ぎたい、パフォーマンス重視のチーム。
- **関連性チェック**: Rails（ActiveRecord）利用なら基本該当。`app/controllers` / `app/components` 配下。
- **オプション**: なし（`Include` はデフォルトで controller/component に限定）。

## Model / Enumerize 系

### `Sgcop/EnumerizeDefaultOption`
- **趣旨**: enumerize の `default:` は予測しない挙動を招くので避け、DB レベルでデフォルト値を設定しよう。
- **なぜ無効**: enumerize を使っていないプロジェクトには無関係。
- **向くプロジェクト**: `enumerize` gem を使っているチーム。
- **関連性チェック**: `Gemfile` に `enumerize` があるか。無ければ現状維持でよい。
- **オプション**: なし。

### `Sgcop/EnumerizePredicatesOption`
- **趣旨**: enumerize の `predicates:` はメソッド名がコンフリクトしやすく定義を追いにくいので制限する。
- **なぜ無効**: enumerize 未使用なら無関係。`predicates` を活用したいチームもいる。
- **向くプロジェクト**: `enumerize` を使い、述語メソッドの乱立を避けたいチーム。
- **関連性チェック**: `Gemfile` の `enumerize`、`app/models` での `enumerize ... predicates:` 利用。
- **オプション**: `AllowWithPrefix`（デフォルト `false`）。
  - `false`: `predicates: true` も `predicates: { prefix: true }` も禁止。
  - `true`: `predicates: { prefix: true }`（プレフィックス付き）なら許可。コンフリクトを避けつつ
    述語メソッドを使いたいチームはこちら。

### `Sgcop/ErrorMessageFormat`
- **趣旨**: バリデーションのエラーメッセージはシンボルで指定しよう。エラー種別で検証することで
  壊れにくいテストになる。
- **なぜ無効**: 既存の文字列メッセージが多いと違反が出る。i18n 運用方針に依存。
- **向くプロジェクト**: i18n でエラーメッセージを管理し、テストをメッセージ文字列に依存させたくないチーム。
- **関連性チェック**: `app/models` / `app/forms` / `app/validators` での `errors.add` に文字列を
  渡している箇所。
- **オプション**: なし。

## Capybara / system spec 系

### `Sgcop/Capybara/FragileSelector`
- **趣旨**: スタイル変更やマークアップ変更で壊れやすいセレクタ（class / id / 部分 href 等）を避け、
  `data` 属性ベースのセレクタを使おう。
- **なぜ無効**: 既存 system spec が CSS セレクタ前提だと違反が大量に出る。
- **向くプロジェクト**: E2E テストを壊れにくくしたい、`data-testid` 等を整備しているチーム。
- **関連性チェック**: `spec/system/**/*_spec.rb` の有無、`find('.foo')` 等の脆弱セレクタ利用。
- **オプション**: なし（`Include` は `spec/system` に限定）。

### `Sgcop/Capybara/FillInArgument`
- **趣旨**: `fill_in` の第 1 引数を「ラベル文字列」か「name 属性」のどちらかに統一しよう。
- **なぜ無効**: どちらに統一するかはチームの好み・既存コードの傾向に依存する。
- **向くプロジェクト**: feature/system/component spec を書くチーム。
- **関連性チェック**: `spec/features` / `spec/system` / `spec/components` の `fill_in` 利用と、
  既存がラベル指定 / name 指定どちらに寄っているか。
- **オプション**: `EnforcedStyle`（`SupportedStyles: [label, name]`、デフォルト `label`）。
  - `label`: 画面に見えるラベル文字列で指定。ユーザー視点に近く可読性が高い。多くの場合の推奨。
  - `name`: input の `name` 属性で指定。ラベルが動的／多言語で揺れる場合に安定する。
  - **推奨の決め方**: 既存 spec がどちらに寄っているかを見て、多数派に合わせるのが摩擦が少ない。
    どちらでもないなら `label` を初期推奨にする。

## RSpec 系（キーは `Sgcop/Rspec/...`）

### `Sgcop/Rspec/ActionMailerTestHelper`
- **趣旨**: `ActionMailer::Base.deliveries` や `have_enqueued_mail` の代わりに
  `ActionMailer::TestHelper`（`assert_emails` 等）を使おう。
- **なぜ無効**: 既存テストのスタイルに依存。チームのアサーション方針による。
- **向くプロジェクト**: メール送信テストを Rails 標準ヘルパーで統一したいチーム。
- **関連性チェック**: `spec/**/*_spec.rb` でのメール関連テスト、`deliveries` / `have_enqueued_mail` 利用。
- **オプション**: なし。

### `Sgcop/Rspec/ActiveJobTestHelper`
- **趣旨**: RSpec の ActiveJob マッチャーの代わりに `ActiveJob::TestHelper`（`assert_enqueued_jobs` 等）を使おう。
- **なぜ無効**: アサーションスタイルの好みに依存。
- **向くプロジェクト**: ジョブのテストを Rails 標準ヘルパーで統一したいチーム。
- **関連性チェック**: `spec/**/*_spec.rb` でのジョブ関連テスト。
- **オプション**: なし。

### `Sgcop/Rspec/NoMethodCallInExpectation`
- **趣旨**: 期待値にはメソッド呼び出しではなくリテラル値を使おう（テストの意図を明確にし、
  プロダクションと同じロジックで検証してしまう事故を防ぐ）。
- **なぜ無効**: `_path` / `I18n.t` などは現実的に呼び出しを許したいケースがあり、運用方針に依存。
- **向くプロジェクト**: 期待値をリテラルで固定し、テストの自己文書性を重視するチーム。
- **関連性チェック**: `spec/**/*_spec.rb` の `expect(...).to eq(some_method)` のような呼び出し。
- **オプション**: `TargetMatchers`（対象マッチャー）、`AllowedPatterns`（許可する呼び出しパターン。
  デフォルトで `_path$` / `_url$` / `I18n.t` / `I18n.l` / `id` / `to_date` / `to_i` / `to_s` を許可）。
  プロジェクト固有に許可したい呼び出しがあれば `AllowedPatterns` に追記する形で調整できる。
