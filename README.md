# Sgcop

SonicGarden標準のrobocop設定支援をするツール

## Installation

```ruby
gem 'sgcop', github: 'SonicGarden/sgcop'
```

#### Opsworks 案件の場合

development の group に入れると、デプロイ時にgemを参照できないというエラーになる場合がある。development group にいれないで以下のように書くことで回避できる。

````ruby
gem 'sgcop', github: 'SonicGarden/sgcop', require: false
````

## Usage

For non-Rails projects, add the following to the top of your .rubocop.yml file:

```
inherit_gem:
  sgcop: ruby/rubocop.yml
```

If your project is a Rails project, you should use the instruction below, which includes all the standard SonicGarden Ruby styles, with Rails-specific cops:

```
inherit_gem:
  sgcop: rails/rubocop.yml
```

And then execute:

```
rubocop <options...>
```

## しつけ方

http://blog.onk.ninja/2015/10/27/rubocop-getting-started

自動修正して楽したいならこちら

http://blog.onk.ninja/2015/10/27/rubocop-getting-started#治安の悪いアプリに-rubocop-を導入する

### その他参考サイト
- Rubcop チートシート http://qiita.com/kitaro_tn/items/abb881c098b3df3f9871
- 設定一覧(本家) https://github.com/bbatsov/rubocop/tree/master/config

### For atom editor user

linter-rubocop https://atom.io/packages/linter-rubocop のパッケージをインストールする
Setting 内で Command の設定を

    bundle exec rubocop

に変更する。
上記の設定をしないと gem になっていないので、 gem が見つかりませんというエラーになる。

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SonicGarden/sgcop. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

