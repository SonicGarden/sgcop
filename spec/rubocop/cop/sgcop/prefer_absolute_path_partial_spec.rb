require 'spec_helper'

describe RuboCop::Cop::Sgcop::PreferAbsolutePathPartial do
  subject(:cop) { described_class.new }

  context '文字列でパーシャルを指定' do
    it '相対パスは警告' do
      expect_offense(<<~RUBY, 'app/views/users/show.html.erb')
        render 'form'
               ^^^^^^ Sgcop/PreferAbsolutePathPartial: パーシャルは絶対パスで指定してください。
      RUBY

      expect_correction(<<~RUBY)
        render "users/form"
      RUBY
    end

    it '絶対パスは警告なし' do
      expect_no_offenses(<<~RUBY)
        render 'users/form'
      RUBY
    end

    it 'shared/のパーシャルは警告なし' do
      expect_no_offenses(<<~RUBY)
        render 'shared/header'
      RUBY
    end
  end

  context 'partial:オプションでパーシャルを指定' do
    it '相対パスは警告' do
      expect_offense(<<~RUBY, 'app/views/users/show.html.erb')
        render partial: 'user_item'
                        ^^^^^^^^^^^ Sgcop/PreferAbsolutePathPartial: パーシャルは絶対パスで指定してください。
      RUBY

      expect_correction(<<~RUBY)
        render partial: "users/user_item"
      RUBY
    end

    it '絶対パスは警告なし' do
      expect_no_offenses(<<~RUBY)
        render partial: 'users/user_item'
      RUBY
    end
  end

  context 'コレクションレンダリング' do
    it '相対パスは警告' do
      expect_offense(<<~RUBY, 'app/views/users/show.html.erb')
        render partial: 'user', collection: @users
                        ^^^^^^ Sgcop/PreferAbsolutePathPartial: パーシャルは絶対パスで指定してください。
      RUBY

      expect_correction(<<~RUBY)
        render partial: "users/user", collection: @users
      RUBY
    end

    it '絶対パスは警告なし' do
      expect_no_offenses(<<~RUBY)
        render partial: 'users/user', collection: @users
      RUBY
    end
  end

  context '異なるディレクトリ構造' do
    it 'ネストしたディレクトリでも正しく絶対パスに変換' do
      expect_offense(<<~RUBY, 'app/views/admin/posts/edit.html.erb')
        render 'form'
               ^^^^^^ Sgcop/PreferAbsolutePathPartial: パーシャルは絶対パスで指定してください。
      RUBY

      expect_correction(<<~RUBY)
        render "admin/posts/form"
      RUBY
    end
  end

  context 'components配下のファイル' do
    it 'コンポーネント内の相対パスも警告' do
      expect_offense(<<~RUBY, 'app/components/button_component.html.erb')
        render 'icon'
               ^^^^^^ Sgcop/PreferAbsolutePathPartial: パーシャルは絶対パスで指定してください。
      RUBY
    end
  end

  context 'renderメソッド以外' do
    it 'render_to_stringは警告なし' do
      expect_no_offenses(<<~RUBY)
        render_to_string 'form'
      RUBY
    end

    it 'partial:以外のオプションは警告なし' do
      expect_no_offenses(<<~RUBY)
        render template: 'form'
      RUBY
    end
  end
end
