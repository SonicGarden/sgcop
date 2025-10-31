# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Sgcop::I18nLazyLookup do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      'Sgcop/I18nLazyLookup' => {
        'EnforcedStyle' => enforced_style,
      }
    )
  end

  context 'EnforcedStyle: explicit (default)' do
    let(:enforced_style) { 'explicit' }

    context 'コントローラー' do
      it 'lazy lookupを使用している場合は警告される' do
        expect_offense(<<~RUBY, 'app/controllers/books_controller.rb')
          class BooksController < ApplicationController
            def create
              redirect_to books_url, notice: t('.success')
                                               ^^^^^^^^^^ Use explicit key for better maintainability.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class BooksController < ApplicationController
            def create
              redirect_to books_url, notice: t('books.create.success')
            end
          end
        RUBY
      end

      it '明示的なキーを使用している場合は警告されない' do
        expect_no_offenses(<<~RUBY, 'app/controllers/books_controller.rb')
          class BooksController < ApplicationController
            def create
              redirect_to books_url, notice: t('books.create.success')
            end
          end
        RUBY
      end

      it 'プライベートメソッド内でも警告される' do
        expect_offense(<<~RUBY, 'app/controllers/books_controller.rb')
          class BooksController < ApplicationController
            private

            def helper_method
              t('.success')
                ^^^^^^^^^^ Use explicit key for better maintainability.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class BooksController < ApplicationController
            private

            def helper_method
              t('books.helper_method.success')
            end
          end
        RUBY
      end
    end

    context 'コンポーネント' do
      it 'lazy lookupを使用している場合は警告される' do
        expect_offense(<<~RUBY, 'app/components/book_component.rb')
          class BookComponent < ViewComponent::Base
            def title
              t('.title')
                ^^^^^^^^ Use explicit key for better maintainability.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class BookComponent < ViewComponent::Base
            def title
              t('book.title')
            end
          end
        RUBY
      end

      it '明示的なキーを使用している場合は警告されない' do
        expect_no_offenses(<<~RUBY, 'app/components/book_component.rb')
          class BookComponent < ViewComponent::Base
            def title
              t('book_component.title')
            end
          end
        RUBY
      end

      it 'ネストしたコンポーネントでも正しく動作する' do
        expect_offense(<<~RUBY, 'app/components/admin/user_card_component.rb')
          class Admin::UserCardComponent < ViewComponent::Base
            def header
              t('.header')
                ^^^^^^^^^ Use explicit key for better maintainability.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Admin::UserCardComponent < ViewComponent::Base
            def header
              t('admin/user_card.header')
            end
          end
        RUBY
      end
    end

    context 'translateメソッド' do
      it 'translateでも警告される' do
        expect_offense(<<~RUBY, 'app/controllers/books_controller.rb')
          class BooksController < ApplicationController
            def index
              @message = translate('.title')
                                   ^^^^^^^^ Use explicit key for better maintainability.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class BooksController < ApplicationController
            def index
              @message = translate('books.index.title')
            end
          end
        RUBY
      end
    end
  end

  context 'EnforcedStyle: lazy' do
    let(:enforced_style) { 'lazy' }

    context 'コントローラー' do
      it '明示的なキーを使用している場合は警告される' do
        expect_offense(<<~RUBY, 'app/controllers/books_controller.rb')
          class BooksController < ApplicationController
            def create
              redirect_to books_url, notice: t('books.create.success')
                                               ^^^^^^^^^^^^^^^^^^^^^^ Use lazy lookup key for better maintainability.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class BooksController < ApplicationController
            def create
              redirect_to books_url, notice: t('.success')
            end
          end
        RUBY
      end

      it 'lazy lookupを使用している場合は警告されない' do
        expect_no_offenses(<<~RUBY, 'app/controllers/books_controller.rb')
          class BooksController < ApplicationController
            def create
              redirect_to books_url, notice: t('.success')
            end
          end
        RUBY
      end
    end
  end
end
