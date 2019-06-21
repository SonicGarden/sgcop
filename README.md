# Sgcop

SonicGarden 標準の rubocop, haml-lint 設定支援をするツール

## Installation

RubyGems.org にリリースしていない gem のため、bundler を使ってインストールする。

```
gem 'sgcop', github: 'SonicGarden/sgcop'
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

### For atom editor user

bundle を使ってインストールしている場合、 [linter-rubocop](https://atom.io/packages/linter-rubocop) のパッケージをインストールする
Setting 内で Command の設定を

    bundle exec rubocop

に変更する。
上記の設定をしないと gem になっていないので、 gem が見つかりませんというエラーになる。

## CircleCI と組み合わせたプルリクエスト自動レビュー

CircleCI 上で rubocop, haml-lint, brakeman を実行して、その結果をプルリクエストにレビューコメントとして自動的に書き込むことができます。

### 共通の設定（セットアップ）

CircleCI の設定 .circleci/config.yml に以下の項目を追加します。

**実行スクリプト**

```yml
- run:
    name: Auto-review setup
    command: gem install specific_install && gem specific_install SonicGarden/sgcop
    when: always
```

そして、 GitHub の Personal Access Token で repo の read/write 権限をもった token を生成して、
CircleCI の環境設定からその token を `GITHUB_ACCESS_TOKEN` という名前でセットしてください。

### rubocop, haml-lint を実行

CircleCI の設定 .circleci/config.yml でセットアップより後に以下の項目を追加します。

**実行スクリプト**

```yml
- run:
    name: Review by Rubocop
    command: sgcop review rubocop
    when: always
```

### brakeman を実行

CircleCI の設定 .circleci/config.yml でセットアップより後に以下の項目を追加します。

**実行スクリプト**

```yml
- run:
    name: Review by Brakeman
    command: sgcop review brakeman
    when: always
```

### サンプル(private repo)

https://github.com/SonicGarden/ishuran/pull/57

このように sg-bot にやらせたい場合は sg-bot の token を remotty などで尋ねてください。

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SonicGarden/sgcop. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
