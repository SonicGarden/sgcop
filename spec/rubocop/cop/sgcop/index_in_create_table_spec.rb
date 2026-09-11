require 'spec_helper'

describe RuboCop::Cop::Sgcop::IndexInCreateTable, :config do
  context '違反を検出する場合' do
    it 'create_tableブロック直後のadd_indexを検出する' do
      expect_offense(<<~RUBY)
        create_table :webhooks, comment: 'Webhook' do |t|
          t.references :user, null: false, foreign_key: true, comment: 'ユーザー'
          t.string :endpoint, null: false, comment: '送信先URL'
          t.string :secret, null: false, comment: '署名シークレット'
          t.timestamps
        end
        add_index :webhooks, :endpoint, unique: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      RUBY

      expect_correction(<<~RUBY)
        create_table :webhooks, comment: 'Webhook' do |t|
          t.references :user, null: false, foreign_key: true, comment: 'ユーザー'
          t.string :endpoint, null: false, comment: '送信先URL'
          t.string :secret, null: false, comment: '署名シークレット'
          t.timestamps
          t.index :endpoint, unique: true
        end
      RUBY
    end

    it '同一テーブルへの2件のadd_indexを順序を保ったまま検出する' do
      expect_offense(<<~RUBY)
        create_table :users do |t|
          t.string :email
          t.string :name
        end
        add_index :users, :email, unique: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
        add_index :users, :name
        ^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      RUBY

      expect_correction(<<~RUBY)
        create_table :users do |t|
          t.string :email
          t.string :name
          t.index :email, unique: true
          t.index :name
        end
      RUBY
    end

    it 'テーブル名がシンボルと文字列で混在していても検出する' do
      expect_offense(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
        add_index 'users', :email
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      RUBY

      expect_correction(<<~RUBY)
        create_table :users do |t|
          t.string :email
          t.index :email
        end
      RUBY
    end

    it '複合インデックスのオプションをすべて引き継ぐ' do
      expect_offense(<<~RUBY)
        create_table :memberships do |t|
          t.integer :user_id
          t.integer :group_id
        end
        add_index :memberships, [:user_id, :group_id], unique: true, name: 'idx_memberships'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      RUBY

      expect_correction(<<~RUBY)
        create_table :memberships do |t|
          t.integer :user_id
          t.integer :group_id
          t.index [:user_id, :group_id], unique: true, name: 'idx_memberships'
        end
      RUBY
    end

    it 'マイグレーションクラスの中でも検出する' do
      expect_offense(<<~RUBY)
        class CreateUsers < ActiveRecord::Migration[7.1]
          def change
            create_table :users do |t|
              t.string :email
            end
            add_index :users, :email, unique: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class CreateUsers < ActiveRecord::Migration[7.1]
          def change
            create_table :users do |t|
              t.string :email
              t.index :email, unique: true
            end
          end
        end
      RUBY
    end

    it '本体が空のcreate_tableブロックにも挿入する' do
      expect_offense(<<~RUBY)
        create_table :users do |t|
        end
        add_index :users, :email
        ^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      RUBY

      expect_correction(<<~RUBY)
        create_table :users do |t|
          t.index :email
        end
      RUBY
    end

    it '本体最終行の行末コメントの後ろに挿入する' do
      expect_offense(<<~RUBY)
        create_table :users do |t|
          t.timestamps # 作成日時
        end
        add_index :users, :email
        ^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      RUBY

      expect_correction(<<~RUBY)
        create_table :users do |t|
          t.timestamps # 作成日時
          t.index :email
        end
      RUBY
    end

    it '複数行のadd_indexのレイアウトを保つ' do
      expect_offense(<<~RUBY)
        create_table :users do |t|
          t.string :a
        end
        add_index :users,
        ^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
                  :a,
                  unique: true
      RUBY

      expect_correction(<<~RUBY)
        create_table :users do |t|
          t.string :a
          t.index :a,
                  unique: true
        end
      RUBY
    end

    it 'add_index行の行末コメントを引き継ぐ' do
      expect_offense(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
        add_index :users, :email # ユーザーごとに一意
        ^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      RUBY

      expect_correction(<<~RUBY)
        create_table :users do |t|
          t.string :email
          t.index :email # ユーザーごとに一意
        end
      RUBY
    end

    it '非マッチのノードが現れた時点で走査を打ち切る' do
      expect_offense(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
        add_index :users, :email
        ^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
        execute 'VACUUM'
        add_index :users, :name
      RUBY

      expect_correction(<<~RUBY)
        create_table :users do |t|
          t.string :email
          t.index :email
        end
        execute 'VACUUM'
        add_index :users, :name
      RUBY
    end
  end

  context '対象外の場合' do
    it '別テーブルへのadd_indexは検出しない' do
      expect_no_offenses(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
        add_index :posts, :user_id
      RUBY
    end

    it 'テーブル名が変数の場合は検出しない' do
      expect_no_offenses(<<~RUBY)
        create_table table_name do |t|
          t.string :email
        end
        add_index table_name, :email
      RUBY
    end

    it 'カラム引数のないadd_indexは検出しない' do
      expect_no_offenses(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
        add_index :users
      RUBY
    end

    it 'if/elseの別の分岐にまたがる場合は検出しない' do
      expect_no_offenses(<<~RUBY)
        if legacy?
          create_table :users do |t|
            t.string :email
          end
        else
          add_index :users, :email
        end
      RUBY
    end

    it 'create_tableが唯一のノードの場合は検出しない' do
      expect_no_offenses(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
      RUBY
    end

    it 'numblock(_1)のcreate_tableは検出しない' do
      expect_no_offenses(<<~RUBY)
        create_table :users do
          _1.string :email
        end
        add_index :users, :email
      RUBY
    end

    context 'ターゲットRubyバージョンがRuby 3.4の場合', :ruby34 do
      it 'itblockのcreate_tableは検出しない' do
        expect_no_offenses(<<~RUBY)
          create_table :users do
            it.string :email
          end
          add_index :users, :email
        RUBY
      end
    end
  end

  context 'オプションを判定する場合' do
    it 'if_not_existsを含むadd_indexは検出しない' do
      expect_no_offenses(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
        add_index :users, :email, if_not_exists: true
      RUBY
    end

    it 'algorithmを含むadd_indexは検出しない' do
      expect_no_offenses(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
        add_index :users, :email, algorithm: :concurrently
      RUBY
    end

    it 'オプションが変数渡しの場合は検出しない' do
      expect_no_offenses(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
        add_index :users, :email, options
      RUBY
    end

    it 'リテラルハッシュとスプラットが混在する場合は検出しない' do
      expect_no_offenses(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
        add_index :users, :email, unique: true, **shared_options
      RUBY
    end

    it '移行できないオプションを持つadd_indexで走査を打ち切る' do
      expect_offense(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
        add_index :users, :email
        ^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
        add_index :users, :name, if_not_exists: true
        add_index :users, :age
      RUBY

      expect_correction(<<~RUBY)
        create_table :users do |t|
          t.string :email
          t.index :email
        end
        add_index :users, :name, if_not_exists: true
        add_index :users, :age
      RUBY
    end
  end

  context '補正をスキップする場合' do
    it '1行のcreate_tableブロックは補正しない' do
      expect_offense(<<~RUBY)
        create_table(:users) { |t| t.string :email }
        add_index :users, :email
        ^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      RUBY

      expect_no_corrections
    end

    it '最終行以外にコメントを持つ複数行のadd_indexは補正しない' do
      expect_offense(<<~RUBY)
        create_table :users do |t|
          t.string :email
        end
        add_index :users, # メールアドレスの一意インデックス
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
                  :email
      RUBY

      expect_no_corrections
    end
  end
end
