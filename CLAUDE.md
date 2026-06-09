# sgcop

SonicGarden 標準の RuboCop 設定と、カスタム Cop を提供する Gem。

## コマンド

```bash
bundle exec rspec          # 全テスト実行
bundle exec rspec spec/rubocop/cop/sgcop/some_cop_spec.rb  # 特定 Cop のテスト
ruby add_doc_links.rb      # rubocop.yml に cop ドキュメントリンクを付加
```

## アーキテクチャ

- `lib/rubocop/cop/sgcop/` — カスタム Cop の実装
- `lib/sgcop.rb` — 全 Cop の require エントリポイント
- `spec/rubocop/cop/` — Cop のテスト（RSpec + RuboCop::RSpec::ExpectOffense）
- `ruby/rubocop.yml` — Ruby プロジェクト向け設定
- `rails/rubocop.yml` — Rails プロジェクト向け設定（ruby を inherit）

## 新しい Cop を追加する手順

1. `lib/rubocop/cop/sgcop/` に Cop ファイルを作成
2. `lib/sgcop.rb` に `require` を追加
3. `spec/rubocop/cop/sgcop/` に対応するテストを追加
4. `rails/rubocop.yml` または `ruby/rubocop.yml` に設定を追加
5. `ruby add_doc_links.rb` でドキュメントリンクを付加
6. `README.md` のカスタムCop一覧テーブルを更新

## Cop のテスト記述

`expect_offense` / `expect_no_offenses` ヘルパーを使う RuboCop 標準テストパターン。
`spec/support/` に共通ヘルパーあり。

## 開発スタイル

RED/TDD で進める。テストを先に書いて失敗（RED）を確認してから実装する。
