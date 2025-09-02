require 'spec_helper'

describe RuboCop::Cop::Sgcop::PreferButtonTo do
  subject(:cop) { described_class.new }

  context 'form_with' do
    it 'detects form_with with single submit button' do
      expect_offense(<<~RUBY)
        form_with url: path, method: :post do |f|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/PreferButtonTo: Use `button_to` instead of a form with a single button.
          f.submit 'フォロー'
        end
      RUBY
    end

    it 'detects form_with with single button' do
      expect_offense(<<~RUBY)
        form_with url: path, method: :delete do |f|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/PreferButtonTo: Use `button_to` instead of a form with a single button.
          f.button '削除'
        end
      RUBY
    end

    it 'does not detect form_with with multiple elements' do
      expect_no_offenses(<<~RUBY)
        form_with model: @user do |f|
          f.text_field :name
          f.submit 'Save'
        end
      RUBY
    end

    it 'does not detect form_with with hidden field and submit' do
      expect_no_offenses(<<~RUBY)
        form_with url: path do |f|
          f.hidden_field :token
          f.submit 'Submit'
        end
      RUBY
    end
  end

  context 'form_for' do
    it 'detects form_for with single submit button' do
      expect_offense(<<~RUBY)
        form_for @project, url: path, method: :post do |f|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/PreferButtonTo: Use `button_to` instead of a form with a single button.
          f.submit 'フォロー'
        end
      RUBY
    end

    it 'detects form_for with single button' do
      expect_offense(<<~RUBY)
        form_for @item, url: path, method: :delete do |f|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/PreferButtonTo: Use `button_to` instead of a form with a single button.
          f.button '削除'
        end
      RUBY
    end

    it 'does not detect form_for with multiple elements' do
      expect_no_offenses(<<~RUBY)
        form_for @user do |f|
          f.label :name
          f.text_field :name
          f.submit 'Save'
        end
      RUBY
    end
  end

  context 'simple_form_for' do
    it 'detects simple_form_for with single submit button' do
      expect_offense(<<~RUBY)
        simple_form_for @user, url: path do |f|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/PreferButtonTo: Use `button_to` instead of a form with a single button.
          f.submit 'アクティベート'
        end
      RUBY
    end

    it 'detects simple_form_for with single button' do
      expect_offense(<<~RUBY)
        simple_form_for @record, url: path, method: :patch do |f|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/PreferButtonTo: Use `button_to` instead of a form with a single button.
          f.button 'キャンセル'
        end
      RUBY
    end

    it 'does not detect simple_form_for with input fields' do
      expect_no_offenses(<<~RUBY)
        simple_form_for @user do |f|
          f.input :email
          f.input :password
          f.submit 'Sign up'
        end
      RUBY
    end
  end

  context 'bootstrap_form_with' do
    it 'detects bootstrap_form_with with single submit button' do
      expect_offense(<<~RUBY)
        bootstrap_form_with url: path, method: :post do |f|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/PreferButtonTo: Use `button_to` instead of a form with a single button.
          f.submit '購読する'
        end
      RUBY
    end

    it 'does not detect bootstrap_form_with with form fields' do
      expect_no_offenses(<<~RUBY)
        bootstrap_form_with model: @user do |f|
          f.text_field :username
          f.submit 'Update'
        end
      RUBY
    end
  end

  context 'bootstrap_form_for' do
    it 'detects bootstrap_form_for with single button' do
      expect_offense(<<~RUBY)
        bootstrap_form_for @item, url: path do |f|
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/PreferButtonTo: Use `button_to` instead of a form with a single button.
          f.button 'アーカイブ'
        end
      RUBY
    end

    it 'does not detect bootstrap_form_for with multiple elements' do
      expect_no_offenses(<<~RUBY)
        bootstrap_form_for @product do |f|
          f.text_field :name
          f.number_field :price
          f.submit 'Create'
        end
      RUBY
    end
  end

  context 'edge cases' do
    it 'does not detect empty form' do
      expect_no_offenses(<<~RUBY)
        form_with url: path do |f|
        end
      RUBY
    end

    it 'does not detect form with only text content' do
      expect_no_offenses(<<~RUBY)
        form_with url: path do |f|
          # Some content here
        end
      RUBY
    end

    it 'does not detect form with custom elements' do
      expect_no_offenses(<<~RUBY)
        form_with url: path do |f|
          render 'shared/form_fields', form: f
          f.submit 'Submit'
        end
      RUBY
    end
  end
end
