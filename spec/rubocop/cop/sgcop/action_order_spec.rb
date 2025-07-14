require 'spec_helper'

describe RuboCop::Cop::Sgcop::ActionOrder do
  subject(:cop) { RuboCop::Cop::Sgcop::ActionOrder.new }

  it '正しい順序のアクションは警告しない' do
    expect_no_offenses(<<~RUBY)
      class UsersController < ApplicationController
        def index
        end

        def show
        end

        def new
        end

        def create
        end

        def edit
        end

        def update
        end

        def destroy
        end
      end
    RUBY
  end

  it '順序が間違っているアクションは警告する' do
    expect_offense(<<~RUBY)
      class UsersController < ApplicationController
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ActionOrder: Controller actions should be ordered: index, show, new, create, edit, update, destroy.
        def show
        end

        def index
        end
      end
    RUBY
  end

  it '一部のアクションのみ存在し正しい順序の場合は警告しない' do
    expect_no_offenses(<<~RUBY)
      class UsersController < ApplicationController
        def index
        end

        def show
        end

        def destroy
        end
      end
    RUBY
  end

  it '一部のアクションのみ存在し順序が間違っている場合は警告する' do
    expect_offense(<<~RUBY)
      class UsersController < ApplicationController
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ActionOrder: Controller actions should be ordered: index, show, new, create, edit, update, destroy.
        def create
        end

        def new
        end
      end
    RUBY
  end

  it 'Controller以外のクラスは警告しない' do
    expect_no_offenses(<<~RUBY)
      class User < ApplicationRecord
        def destroy
        end

        def show
        end
      end
    RUBY
  end

  it 'RESTアクション以外のメソッドがある場合は無視する' do
    expect_no_offenses(<<~RUBY)
      class UsersController < ApplicationController
        def index
        end

        def custom_method
        end

        def show
        end

        def another_custom_method
        end

        def new
        end
      end
    RUBY
  end

  it 'RESTアクション以外のメソッドと順序が間違っているRESTアクションの場合は警告する' do
    expect_offense(<<~RUBY)
      class UsersController < ApplicationController
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ActionOrder: Controller actions should be ordered: index, show, new, create, edit, update, destroy.
        def custom_method
        end

        def show
        end

        def index
        end
      end
    RUBY
  end

  it 'アクションが存在しない場合は警告しない' do
    expect_no_offenses(<<~RUBY)
      class UsersController < ApplicationController
        def custom_method
        end

        def another_custom_method
        end
      end
    RUBY
  end

  context 'autocorrect' do
    it '順序が間違っているアクションを正しい順序に修正する' do
      expect_offense(<<~RUBY)
        class UsersController < ApplicationController
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ActionOrder: Controller actions should be ordered: index, show, new, create, edit, update, destroy.
          def show
          end

          def index
          end

          def destroy
          end

          def new
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class UsersController < ApplicationController
          def index
          end

          def show
          end

          def new
          end

          def destroy
          end
        end
      RUBY
    end

    it '一部のアクションの順序を修正する' do
      expect_offense(<<~RUBY)
        class UsersController < ApplicationController
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ActionOrder: Controller actions should be ordered: index, show, new, create, edit, update, destroy.
          def create
          end

          def new
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class UsersController < ApplicationController
          def new
          end

          def create
          end
        end
      RUBY
    end

    it 'RESTアクション以外のメソッドは位置を保持する' do
      expect_offense(<<~RUBY)
        class UsersController < ApplicationController
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ActionOrder: Controller actions should be ordered: index, show, new, create, edit, update, destroy.
          def custom_method
          end

          def show
          end

          def index
          end

          def another_method
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class UsersController < ApplicationController
          def custom_method
          end

          def index
          end

          def show
          end

          def another_method
          end
        end
      RUBY
    end
  end
end