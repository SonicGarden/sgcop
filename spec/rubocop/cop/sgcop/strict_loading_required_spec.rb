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

  context '同じ変数への再代入の場合' do
    it '先行する代入がないためインスタンス変数への自己再代入は警告される' do
      expect_offense(<<~RUBY)
        @students = @students.preload(:review)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end

    it '先行する代入がないためローカル変数への自己再代入は警告される' do
      expect_offense(<<~RUBY)
        users = users.includes(:posts)
                ^^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end

    it '複数行チェーンの自己再代入は警告されない' do
      expect_no_offenses(<<~RUBY)
        @students = @search_form.search.strict_loading.preload(user: :company)
        @students = @students
          .preload(:review)
          .order(:created_at)
      RUBY
    end

    it '起点にstrict_loadingがない場合は起点だけが警告される' do
      expect_offense(<<~RUBY)
        @students = @search_form.search.preload(user: :company)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
        @students = @students.preload(:review)
      RUBY
    end

    it '別名の変数を起点にした代入は警告される' do
      expect_offense(<<~RUBY)
        users = User.all
        filtered = users.includes(:posts)
                   ^^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end

    it 'レシーバのないメソッド呼び出しを起点にした代入は警告される' do
      expect_offense(<<~RUBY)
        users = other.includes(:posts)
                ^^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end
  end

  context '起点を遡って判定する場合' do
    it '起点にincludes/preloadがない場合は自己再代入が警告される' do
      expect_offense(<<~RUBY)
        users = User.all
        users = users.includes(:posts)
                ^^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end

    it '目印のない自己再代入が挟まっていても起点まで遡って警告される' do
      expect_offense(<<~RUBY)
        @s = Student.all
        @s = @s.where(active: true)
        @s = @s.preload(:b)
             ^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end

    it '起点がstrict_loadingで中継を経て警告されない' do
      expect_no_offenses(<<~RUBY)
        users = User.all.strict_loading
        users = users.where(active: true)
        users = users.preload(:posts)
      RUBY
    end

    it '同じdef内に起点がある場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        def call
          users = User.all.strict_loading
          users = users.preload(:posts)
        end
      RUBY
    end

    it '別のdefで設定されたivarが起点の場合は警告される' do
      expect_offense(<<~RUBY)
        def set_students
          @s = Student.all.strict_loading
        end

        def call
          @s = @s.preload(:b)
               ^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
        end
      RUBY
    end

    it 'メソッド引数由来の再代入は起点不明として警告される' do
      expect_offense(<<~RUBY)
        def foo(users)
          users = users.includes(:posts)
                  ^^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
        end
      RUBY
    end

    it 'ブロック内の再代入で起点がブロック外の場合は警告される' do
      expect_offense(<<~RUBY)
        users = User.all.strict_loading
        [1].each do
          users = users.preload(:posts)
                  ^^^^^^^^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
        end
      RUBY
    end

    it 'if節内の再代入で起点がdef直下の場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        def call
          users = User.all.strict_loading
          if true
            users = users.preload(:posts)
          end
        end
      RUBY
    end

    it 'or_asgnが起点の場合は警告される' do
      expect_offense(<<~RUBY)
        @s ||= Student.all.strict_loading
        @s = @s.preload(:b)
             ^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end

    it '多重代入が起点の場合は警告される' do
      expect_offense(<<~RUBY)
        a, @s = 1, Student.all.strict_loading
        @s = @s.preload(:b)
             ^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
      RUBY
    end

    it '別のクラス本体のivarは起点とみなさず警告される' do
      expect_offense(<<~RUBY)
        class A
          @s = Student.all.strict_loading
        end
        class B
          @s = @s.preload(:b)
               ^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
        end
      RUBY
    end

    it '別のモジュール本体のivarは起点とみなさず警告される' do
      expect_offense(<<~RUBY)
        module M
          @s = Student.all.strict_loading
        end
        module N
          @s = @s.preload(:b)
               ^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
        end
      RUBY
    end

    it '特異クラスのivarは起点とみなさず警告される' do
      expect_offense(<<~RUBY)
        class C
          class << self
            @s = Student.all.strict_loading
          end
          @s = @s.preload(:b)
               ^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
        end
      RUBY
    end

    it '起点の変数の型が異なる場合は警告される' do
      expect_offense(<<~RUBY)
        s = Student.all.strict_loading
        @s = @s.preload(:b)
             ^^^^^^^^^^^^^^ Sgcop/StrictLoadingRequired: Add `.strict_loading` when using `includes` or `preload` with variable assignment
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
