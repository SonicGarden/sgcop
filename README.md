# Sgcop

SonicGarden標準のrubocop設定支援をするツール

## Installation

```ruby
gem 'sgcop', github: 'SonicGarden/sgcop'
```

#### Opsworks 案件の場合

development の group に入れると、デプロイ時にgemを参照できないというエラーになる場合がある。development group にいれないで以下のように書くことで回避できる。
理由は[こちら](https://www.remotty.net/groups/13/entries/119357)

````ruby
gem 'sgcop', github: 'SonicGarden/sgcop', require: false
````

### RubyMine
RubyMine 2017.1 から標準のコード解析機能で rubocop が使えるようになっているが、 bundler を使わずに実行されるため、 `gem 'sgcop', github: ...`  形式でインストールされた sgcop が使用できない。
specific_install gem を使って、グローバルな gem として sgcop をインストールすれば使えるようになる。

```
$ gem install specific_install
$ gem specific_install SonicGarden/sgcop
```

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

### 参考サイト
- Rubocop チートシート http://qiita.com/kitaro_tn/items/abb881c098b3df3f9871
- 設定一覧(本家) https://github.com/bbatsov/rubocop/tree/master/config

### For atom editor user

linter-rubocop https://atom.io/packages/linter-rubocop のパッケージをインストールする
Setting 内で Command の設定を

    bundle exec rubocop

に変更する。
上記の設定をしないと gem になっていないので、 gem が見つかりませんというエラーになる。

## werckerと組み合わせたプルリクエスト自動コメント

werckerを利用している場合、wercker上でrubocopを実行して、その結果をプルリクエストにレビューコメントとして自動的に書き込むことができます。

### werckerの設定方法

1. Gemfile の `gem 'sgcop'` を test group に入れる

2. このgemの [exe/run-rubocop.sh](https://github.com/SonicGarden/sgcop/tree/master/exe/run-rubocop.sh) をプロジェクトの bin/rubocop.sh にコピーし、実行権限を付加(`chmod +x`)
（コピーしなくてもgem内のスクリプトを直接実行する方法があったら教えてください :pray:）
3. .wercker.yml に以下の項目を追加

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

4. GitHub の Personal Access Token でrepoのread/write権限をもったtokenを生成

5. werckerの Application settings - Environment variables でそのtokenを `GITHUB_ACCESS_TOKEN` にprotectedでセット

### サンプル(private repo)
https://github.com/SonicGarden/ishuran/pull/57

このように sg-bot にやらせたい場合はtokenを尋ねてください。


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SonicGarden/sgcop. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

