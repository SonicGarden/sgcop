require 'spec_helper'

describe RuboCop::Cop::Sgcop::DuplicateIndexInSchema do
  subject(:cop) { RuboCop::Cop::Sgcop::DuplicateIndexInSchema.new }

  context 'schema.rbファイル内で' do
    it '包含関係にあるインデックスを検出する' do
      expect_offense(<<~RUBY)
        ActiveRecord::Schema[7.0].define(version: 2024_01_01_000000) do
          create_table "table1", force: :cascade do |t|
            t.bigint "col_a"
            t.bigint "col_b"
            t.index ["col_a", "col_b"], name: "index_table1_on_col_a_and_col_b"
            t.index ["col_a"], name: "index_table1_on_col_a"
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/DuplicateIndexInSchema: インデックス`index_table1_on_col_a`は`index_table1_on_col_a_and_col_b`に含まれているため不要です
          end
        end
      RUBY
    end

    it '3カラムのインデックスが2カラムのインデックスを包含する場合を検出する' do
      expect_offense(<<~RUBY)
        ActiveRecord::Schema[7.0].define(version: 2024_01_01_000000) do
          create_table "table2", force: :cascade do |t|
            t.integer "col_x"
            t.integer "col_y"
            t.integer "col_z"
            t.index ["col_x", "col_y", "col_z"], name: "index_table2_on_x_y_z"
            t.index ["col_x", "col_y"], name: "index_table2_on_x_y"
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/DuplicateIndexInSchema: インデックス`index_table2_on_x_y`は`index_table2_on_x_y_z`に含まれているため不要です
            t.index ["col_x"], name: "index_table2_on_x"
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/DuplicateIndexInSchema: インデックス`index_table2_on_x`は`index_table2_on_x_y_z`に含まれているため不要です
          end
        end
      RUBY
    end

    it '単一カラムのインデックスが複数カラムのインデックスを包含する場合を検出する' do
      expect_offense(<<~RUBY)
        ActiveRecord::Schema[7.0].define(version: 2024_01_01_000000) do
          create_table "table3", force: :cascade do |t|
            t.integer "field_a"
            t.integer "field_b"
            t.index ["field_a", "field_b"], name: "index_table3_on_a_and_b"
            t.index ["field_a"], name: "index_table3_on_a"
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/DuplicateIndexInSchema: インデックス`index_table3_on_a`は`index_table3_on_a_and_b`に含まれているため不要です
          end
        end
      RUBY
    end

    it '重複しないインデックスの場合は警告しない' do
      expect_no_offenses(<<~RUBY)
        ActiveRecord::Schema[7.0].define(version: 2024_01_01_000000) do
          create_table "table4", force: :cascade do |t|
            t.integer "foo"
            t.integer "bar"
            t.integer "baz"
            t.index ["foo"], name: "index_table4_on_foo"
            t.index ["bar"], name: "index_table4_on_bar"
            t.index ["baz"], name: "index_table4_on_baz"
          end
        end
      RUBY
    end

    it '逆順のインデックスは重複とみなさない' do
      expect_no_offenses(<<~RUBY)
        ActiveRecord::Schema[7.0].define(version: 2024_01_01_000000) do
          create_table "table5", force: :cascade do |t|
            t.integer "alpha"
            t.integer "beta"
            t.index ["alpha", "beta"], name: "index_table5_on_alpha_beta"
            t.index ["beta", "alpha"], name: "index_table5_on_beta_alpha"
          end
        end
      RUBY
    end

    it '文字列とシンボルの両方のカラム指定を扱える' do
      expect_offense(<<~RUBY)
        ActiveRecord::Schema[7.0].define(version: 2024_01_01_000000) do
          create_table "table6", force: :cascade do |t|
            t.integer "item_a"
            t.integer "item_b"
            t.index [:item_a, :item_b], name: "index_table6_on_a_and_b"
            t.index :item_a, name: "index_table6_on_a"
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/DuplicateIndexInSchema: インデックス`index_table6_on_a`は`index_table6_on_a_and_b`に含まれているため不要です
          end
        end
      RUBY
    end
  end
end
