# Sgcop

SonicGarden 標準の rubocop設定支援をするツール

## Installation

```
gem 'sgcop', github: 'SonicGarden/sgcop', branch: 'main'
```

## Usage

SonicGarden 標準スタイルを用意しています。

プロジェクトルートに .rubocop.yml ファイルをつくり、Rails ではないプロジェクトの場合は以下のように書く。

```
inherit_gem:
  sgcop: ruby/rubocop.yml
```

Rails プロジェクトの場合は以下のように書く。

```
inherit_gem:
  sgcop: rails/rubocop.yml
```

そして実行。

```
rubocop <options...>
```

## カスタムCop一覧

sgcopが提供するカスタムCopの一覧です。

### Rails関連

| Cop名 | 説明 | デフォルト |
|-------|------|:----------:|
| [`Sgcop/ActiveJobQueueAdapter`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/active_job_queue_adapter.rb) | ActiveJobのキューアダプタ設定をチェック | ✅ |
| [`Sgcop/LoadDefaultsVersionMatch`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/load_defaults_version_match.rb) | config.load_defaultsのバージョンがRailsバージョンと一致することを確認 | ✅ |
| [`Sgcop/NestedResourcesWithoutModule`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/nested_resources_without_module.rb) | ネストされたルーティングでmoduleオプションの使用を推奨 | ❌ |
| [`Sgcop/NoAcceptsNestedAttributesFor`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/no_accepts_nested_attributes_for.rb) | accepts_nested_attributes_forの使用を制限 | ❌ |
| [`Sgcop/ErrorMessageFormat`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/error_message_format.rb) | エラーメッセージはシンボルを使用することを強制 | ❌ |
| [`Sgcop/OnLoadArguments`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/on_load_arguments.rb) | on_loadブロックの引数使用をチェック | ✅ |
| [`Sgcop/RequestRemoteIp`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/request_remote_ip.rb) | request.remote_ipの適切な使用を確認 | ✅ |
| [`Sgcop/ResourceActionOrder`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/resource_action_order.rb) | resourcesルーティングのアクション順序を統一 | ✅ |
| [`Sgcop/ResourcesWithoutOnly`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/resources_without_only.rb) | resourcesルーティングでonlyオプションの使用を推奨 | ✅ |
| [`Sgcop/RetryOnInfiniteAttempts`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/retry_on_infinite_attempts.rb) | retry_onでの無限リトライを防止 | ✅ |
| [`Sgcop/SimpleFormat`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/simple_format.rb) | simple_formatメソッドの安全な使用を確認 | ✅ |
| [`Sgcop/SimpleFormAssociation`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/simple_form_association.rb) | SimpleFormのassociationメソッドの適切な使用をチェック | ✅ |
| [`Sgcop/StrictLoadingRequired`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/strict_loading_required.rb) | N+1問題を防ぐstrict_loadingの使用を推奨 | ❌ |
| [`Sgcop/TransactionRequiresNew`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/transaction_requires_new.rb) | requires_new: trueを使用したトランザクションをチェック | ✅ |
| [`Sgcop/UjsOptions`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/ujs_options.rb) | Rails UJSオプションの適切な使用を確認 | ✅ |
| [`Sgcop/Unscoped`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/unscoped.rb) | unscopedメソッドの使用を制限 | ✅ |

### Capybara関連

| Cop名 | 説明 | デフォルト |
|-------|------|:----------:|
| [`Sgcop/Capybara/FragileSelector`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/capybara/fragile_selector.rb) | 脆弱なCSSセレクタの使用を防止（data属性の使用を推奨） | ❌ |
| [`Sgcop/Capybara/Matchers`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/capybara/matchers.rb) | Capybaraマッチャーの適切な使用をチェック | ✅ |
| [`Sgcop/Capybara/Sleep`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/capybara/sleep.rb) | テストでのsleepの使用を制限 | ✅ |

### RSpec関連

| Cop名 | 説明 | デフォルト |
|-------|------|:----------:|
| [`Sgcop/RSpec/ActionMailerTestHelper`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/rspec/action_mailer_test_helper.rb) | ActionMailerテストヘルパーの適切な使用を確認 | ❌ |

### その他

| Cop名 | 説明 | デフォルト |
|-------|------|:----------:|
| [`Sgcop/EnumerizeDefaultOption`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/enumerize_default_option.rb) | Enumerizeのdefaultオプションの使用をチェック | ❌ |
| [`Sgcop/HashFetchDefault`](https://github.com/SonicGarden/sgcop/blob/main/lib/rubocop/cop/sgcop/hash_fetch_default.rb) | Hash#fetchのデフォルト値の適切な使用を確認 | ✅ |

## しつけ方

http://blog.onk.ninja/2015/10/27/rubocop-getting-started

自動修正して楽したいならこちら

http://blog.onk.ninja/2015/10/27/rubocop-getting-started#治安の悪いアプリに-rubocop-を導入する

### 参考サイト

- Rubocop チートシート http://qiita.com/kitaro_tn/items/abb881c098b3df3f9871
- 設定一覧(本家) https://github.com/bbatsov/rubocop/tree/master/config

## 設定ファイルにドキュメントのリンクを付加するスクリプト(sgcop 開発者向け)

ruby/rubocop.yml, rails/rubocop.yml に新しい cop(ルール)設定を追加した後、以下のコマンドを実行すると、rubocop の cop のドキュメントへのリンクをコメントとして追加します。

```
ruby add_doc_links.rb
```

### 追加されるコメントの例

```
# https://docs.rubocop.org/rubocop/cops_style.html#styleasciicomments
Style/AsciiComments:
  Enabled: false
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SonicGarden/sgcop. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
