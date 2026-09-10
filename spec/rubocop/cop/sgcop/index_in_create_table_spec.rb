require 'spec_helper'

describe RuboCop::Cop::Sgcop::IndexInCreateTable, :config do
  it 'registers an offense for an add_index following a create_table block' do
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

  it 'registers offenses for two add_index calls on the same table and keeps their order' do
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

  it 'registers an offense when the table name mixes a symbol and a string' do
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

  it 'keeps all options of a composite index' do
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

  it 'registers an offense inside def up' do
    expect_offense(<<~RUBY)
      def up
        create_table :users do |t|
          t.string :email
        end
        add_index :users, :email
        ^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      end
    RUBY

    expect_correction(<<~RUBY)
      def up
        create_table :users do |t|
          t.string :email
          t.index :email
        end
      end
    RUBY
  end

  it 'registers an offense inside a reversible block' do
    expect_offense(<<~RUBY)
      reversible do |dir|
        create_table :users do |t|
          t.string :email
        end
        add_index :users, :email
        ^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      end
    RUBY

    expect_correction(<<~RUBY)
      reversible do |dir|
        create_table :users do |t|
          t.string :email
          t.index :email
        end
      end
    RUBY
  end

  it 'registers an offense inside a migration class body' do
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

  it 'appends after an existing t.index without touching it' do
    expect_offense(<<~RUBY)
      create_table :users do |t|
        t.string :email
        t.index :email
      end
      add_index :users, :name
      ^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
    RUBY

    expect_correction(<<~RUBY)
      create_table :users do |t|
        t.string :email
        t.index :email
        t.index :name
      end
    RUBY
  end

  it 'inserts after a trailing comment on the last body line' do
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

  it 'keeps the layout of a multiline add_index' do
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

  it 'leaves following unrelated statements in place' do
    expect_offense(<<~RUBY)
      create_table :users do |t|
        t.string :a
      end
      add_index :users, :a
      ^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      puts 1
    RUBY

    expect_correction(<<~RUBY)
      create_table :users do |t|
        t.string :a
        t.index :a
      end
      puts 1
    RUBY
  end

  it 'registers an offense for a create_table block with a single body node' do
    expect_offense(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_index :users, :email
      ^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
    RUBY

    expect_correction(<<~RUBY)
      create_table :users do |t|
        t.string :email
        t.index :email
      end
    RUBY
  end

  it 'registers an offense for a create_table block with an empty body' do
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

  it 'stops scanning at the first non-matching node' do
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

  it 'does not register an offense for an add_index on another table' do
    expect_no_offenses(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_index :posts, :user_id
    RUBY
  end

  it 'does not register an offense when a non-matching node is in between' do
    expect_no_offenses(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_column :users, :age, :integer
      add_index :users, :email
    RUBY
  end

  it 'does not register an offense for a variable table name' do
    expect_no_offenses(<<~RUBY)
      create_table table_name do |t|
        t.string :email
      end
      add_index table_name, :email
    RUBY
  end

  it 'does not register an offense for a create_table without a block' do
    expect_no_offenses(<<~RUBY)
      create_table :users
      add_index :users, :email
    RUBY
  end

  it 'does not register an offense for an add_index without a column argument' do
    expect_no_offenses(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_index :users
    RUBY
  end

  it 'does not register an offense across if/else branches' do
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

  it 'does not register an offense when create_table is the only node' do
    expect_no_offenses(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
    RUBY
  end

  it 'does not register an offense for a numblock create_table' do
    expect_no_offenses(<<~RUBY)
      create_table :users do
        _1.string :email
      end
      add_index :users, :email
    RUBY
  end

  context 'when the target ruby version is 3.4', :ruby34 do
    it 'does not register an offense for an itblock create_table' do
      expect_no_offenses(<<~RUBY)
        create_table :users do
          it.string :email
        end
        add_index :users, :email
      RUBY
    end
  end

  it 'does not correct a single-line create_table block' do
    expect_offense(<<~RUBY)
      create_table(:users) { |t| t.string :email }
      add_index :users, :email
      ^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
    RUBY

    expect_no_corrections
  end

  it 'carries over a trailing comment on the add_index line' do
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

  it 'carries over trailing comments for two add_index calls' do
    expect_offense(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_index :users, :email # 一意
      ^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
      add_index :users, :name
      ^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
    RUBY

    expect_correction(<<~RUBY)
      create_table :users do |t|
        t.string :email
        t.index :email # 一意
        t.index :name
      end
    RUBY
  end

  it 'does not correct a multiline add_index carrying a comment on a non-final line' do
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

  it 'does not register an offense when options come from a double splat' do
    expect_no_offenses(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_index :users, :email, **shared_options
    RUBY
  end

  it 'does not register an offense when options come from a variable' do
    expect_no_offenses(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_index :users, :email, options
    RUBY
  end

  it 'does not register an offense when a literal hash is merged with a splat' do
    expect_no_offenses(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_index :users, :email, unique: true, **shared_options
    RUBY
  end

  it 'does not register an offense for add_index with if_not_exists' do
    expect_no_offenses(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_index :users, :email, if_not_exists: true
    RUBY
  end

  it 'does not register an offense for add_index with algorithm' do
    expect_no_offenses(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_index :users, :email, algorithm: :concurrently
    RUBY
  end

  it 'stops scanning at an add_index with an unsafe option' do
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

  it 'still registers an offense for safe options' do
    expect_offense(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_index :users, :email, unique: true, where: 'active', using: :btree, name: 'idx'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
    RUBY

    expect_correction(<<~RUBY)
      create_table :users do |t|
        t.string :email
        t.index :email, unique: true, where: 'active', using: :btree, name: 'idx'
      end
    RUBY
  end

  it 'does not crash when the last argument is not a hash' do
    expect_offense(<<~RUBY)
      create_table :users do |t|
        t.string :email
      end
      add_index :users, [:email, :name]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.
    RUBY

    expect_correction(<<~RUBY)
      create_table :users do |t|
        t.string :email
        t.index [:email, :name]
      end
    RUBY
  end
end
