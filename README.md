# Sgcop

SonicGarden 標準の rubocop, haml-lint 設定支援をするツール

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

haml-lint は inherit_gem に相当する機能がないため、プロジェクトルートに .haml-lint.yml ファイルをつくり、この gem の [haml/haml-lint.yml](https://github.com/SonicGarden/sgcop/tree/master/haml/haml-lint.yml) をコピーする。

そして実行。

```
haml-lint app/views/
```

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
