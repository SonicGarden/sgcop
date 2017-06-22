# Sgcop

SonicGarden標準の rubocop, haml-lint 設定支援をするツール

## Installation

RubyGems.org にリリースしていないgemのため、specific_install gem を使ってインストールする。
```
$ gem install specific_install
$ gem specific_install SonicGarden/sgcop
```

bundler を使用する場合（非推奨）

```ruby
gem 'sgcop', github: 'SonicGarden/sgcop'
```

#### Opsworks 案件の場合

development の group に入れると、デプロイ時にgemを参照できないというエラーになる場合がある。development group にいれないで以下のように書くことで回避できる。
理由は[こちら](https://www.remotty.net/groups/13/entries/119357)

````ruby
gem 'sgcop', github: 'SonicGarden/sgcop', require: false
````


## Usage

SonicGarden標準スタイルを用意しています。

プロジェクトルートに .rubocop.yml ファイルをつくり、Railsではないプロジェクトの場合は以下のように書く。

```
inherit_gem:
  sgcop: ruby/rubocop.yml
```

Railsプロジェクトの場合は以下のように書く。

```
inherit_gem:
  sgcop: rails/rubocop.yml
```

そして実行。

```
rubocop <options...>
```

haml-lintは inherit_gem に相当する機能がないため、プロジェクトルートに .haml-lint.yml ファイルをつくり、このgemの [haml/haml-lint.yml](https://github.com/SonicGarden/sgcop/tree/master/haml/haml-lint.yml) をコピーする。

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

bundleを使ってインストールしている場合、 [linter-rubocop](https://atom.io/packages/linter-rubocop) のパッケージをインストールする
Setting 内で Command の設定を

    bundle exec rubocop

に変更する。
上記の設定をしないと gem になっていないので、 gem が見つかりませんというエラーになる。

## CircleCI/Werckerと組み合わせたプルリクエスト自動レビューコメント

CIを利用している場合、CI上でrubocopとhaml-lintを実行して、その結果をプルリクエストにレビューコメントとして自動的に書き込むことができます。

### 実行スクリプトの設定

このgemの [exe/run-rubocop.sh](https://github.com/SonicGarden/sgcop/tree/master/exe/run-rubocop.sh) をプロジェクトの bin/rubocop.sh にコピーし、実行権限を付加(`chmod +x`)します。

CIの設定に以下の項目を追加します。

#### CircleCIの場合
設定ファイルは circle.yml

**実行スクリプト**
```yml
test:
  post:
    - bin/run-rubocop.sh
```

#### Werckerの場合
設定ファイルは .wercker.yml

**rubyのデフォルトエンコーディングをUTF-8に設定**
（boxによってはいらないかも）
```yml
    - script:
      name: set env
      code: export RUBYOPT=-EUTF-8
```

**実行スクリプト**
```yml
    - script:
      name: Run Rubocop and Report by Saddler
      code: bin/run-rubocop.sh
```

### トークンの設定

そして、 GitHub の Personal Access Token でrepoのread/write権限をもったtokenを生成して、
CIの環境設定からそのtokenを `GITHUB_ACCESS_TOKEN` という名前でセットしてください。

Werckerの場合、Protected Variables としてセットしてください。

### サンプル(private repo)
https://github.com/SonicGarden/ishuran/pull/57

このように sg-bot にやらせたい場合は sg-bot のtokenをremottyなどで尋ねてください。


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SonicGarden/sgcop. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

