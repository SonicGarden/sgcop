require 'spec_helper'

describe RuboCop::Cop::Sgcop::Unscoped do
  subject(:cop) { RuboCop::Cop::Sgcop::Unscoped.new }

  it 'unscoped が含まれている場合は警告される' do
    expect_offense(<<~RUBY)
      class BooksController < ApplicationController
        def index
          @books = books.unscoped.default_order
                   ^^^^^^^^^^^^^^ Do not use `unscoped`
        end
      end
    RUBY
  end

  it 'unscoped が含まれていない場合は警告されない' do
    expect_no_offenses(<<~RUBY)
      class BooksController < ApplicationController
        def index
          @books = books.default_order
        end
      end
    RUBY
  end
end
