require 'spec_helper'

describe RuboCop::Cop::Sgcop::CanCanCanResourceAuthorization do
  subject(:cop) { RuboCop::Cop::Sgcop::CanCanCanResourceAuthorization.new }

  it '権限確認メソッドがなければ警告' do
    expect_offense(<<~RUBY)
      class ArticlesController < ApplicationController
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing resource authorization.
      end
    RUBY
  end

  it 'load_and_authorize_resource があれば警告なし' do
    expect_no_offenses(<<~RUBY)
      class ArticlesController < ApplicationController
        load_and_authorize_resource
      end
    RUBY
  end

  it 'authorize_resource があれば警告なし' do
    expect_no_offenses(<<~RUBY)
      class ArticlesController < ApplicationController
        authorize_resource class: Article
      end
    RUBY
  end

  it 'authorize! があれば警告なし' do
    expect_no_offenses(<<~RUBY)
      class ArticlesController < ApplicationController
        def edit
          authorize! :read, @article
        end
      end
    RUBY
  end
end
