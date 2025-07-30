require 'spec_helper'

describe RuboCop::Cop::Sgcop::StrictLoadingRequired do
  subject(:cop) { RuboCop::Cop::Sgcop::StrictLoadingRequired.new }

  context 'includesメソッドが使用されている場合' do
    it 'strict_loadingが含まれていない場合は警告される' do
      expect_offense(<<~RUBY)
        users = User.includes(:posts)
                ^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end

    it 'strict_loadingが含まれている場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        users = User.includes(:posts).strict_loading
      RUBY
    end

    it 'strict_loadingが先に呼ばれている場合も警告されない' do
      expect_no_offenses(<<~RUBY)
        users = User.strict_loading.includes(:posts)
      RUBY
    end
  end

  context 'preloadメソッドが使用されている場合' do
    it 'strict_loadingが含まれていない場合は警告される' do
      expect_offense(<<~RUBY)
        articles = Article.preload(:comments)
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end

    it 'strict_loadingが含まれている場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        articles = Article.preload(:comments).strict_loading
      RUBY
    end
  end

  context '複雑なメソッドチェーンの場合' do
    it 'includesとstrict_loadingが一緒に呼ばれている場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        users = User.where(active: true).includes(:posts).strict_loading.order(:name)
      RUBY
    end

    it 'preloadとwhereチェーンでstrict_loadingがない場合は警告される' do
      expect_offense(<<~RUBY)
        users = User.where(active: true).preload(:posts).order(:name)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end
  end

  context '異なる変数代入タイプの場合' do
    it 'インスタンス変数への代入でも警告される' do
      expect_offense(<<~RUBY)
        @users = User.includes(:posts)
                 ^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end
  end

  context '変数代入されていない場合' do
    it 'スコープ定義では警告されない' do
      expect_no_offenses(<<~RUBY)
        scope :with_posts, -> { includes(:posts) }
      RUBY
    end

    it '直接使用されている場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        User.includes(:posts).each { |u| puts u.name }
      RUBY
    end

    it 'メソッドのreturn値として使用されている場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        def users_with_posts
          User.includes(:posts)
        end
      RUBY
    end
  end

  context '複数のアソシエーションを含む場合' do
    it 'includesで複数のアソシエーションを指定してもstrict_loadingがない場合は警告される' do
      expect_offense(<<~RUBY)
        users = User.includes(:posts, :comments)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end

    it 'ネストしたアソシエーションでもstrict_loadingがない場合は警告される' do
      expect_offense(<<~RUBY)
        users = User.includes(posts: :comments)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end
  end
end
