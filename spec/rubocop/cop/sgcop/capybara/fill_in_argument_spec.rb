require 'spec_helper'

describe RuboCop::Cop::Sgcop::Capybara::FillInArgument, :config do
  context 'EnforcedStyle: label' do
    let(:cop_config) { { 'EnforcedStyle' => 'label' } }

    it 'registers an offense for Rails name attribute form (角括弧)' do
      expect_offense(<<~RUBY)
        fill_in 'user[email]', with: 'x'
                ^^^^^^^^^^^^^ fill_in の引数はラベルテキストで統一しよう（name属性ではなく）。
      RUBY
    end

    it 'registers an offense for snake_case name attribute' do
      expect_offense(<<~RUBY)
        fill_in 'first_name', with: 'x'
                ^^^^^^^^^^^^ fill_in の引数はラベルテキストで統一しよう（name属性ではなく）。
      RUBY
    end

    it 'does not register an offense for Japanese label' do
      expect_no_offenses(<<~RUBY)
        fill_in 'メールアドレス', with: 'x'
      RUBY
    end

    it 'does not register an offense for label with whitespace' do
      expect_no_offenses(<<~RUBY)
        fill_in 'Email address', with: 'x'
      RUBY
    end

    it 'does not register an offense for ambiguous single word' do
      expect_no_offenses(<<~RUBY)
        fill_in 'email', with: 'x'
      RUBY
    end

    it 'does not register an offense for non-string locator' do
      expect_no_offenses(<<~RUBY)
        fill_in field, with: 'x'
      RUBY
    end
  end

  context 'EnforcedStyle: name' do
    let(:cop_config) { { 'EnforcedStyle' => 'name' } }

    it 'registers an offense for Japanese label' do
      expect_offense(<<~RUBY)
        fill_in 'メールアドレス', with: 'x'
                ^^^^^^^^^ fill_in の引数はname属性で統一しよう（ラベルテキストではなく）。
      RUBY
    end

    it 'registers an offense for label with whitespace' do
      expect_offense(<<~RUBY)
        fill_in 'Email address', with: 'x'
                ^^^^^^^^^^^^^^^ fill_in の引数はname属性で統一しよう（ラベルテキストではなく）。
      RUBY
    end

    it 'does not register an offense for Rails name attribute form' do
      expect_no_offenses(<<~RUBY)
        fill_in 'user[email]', with: 'x'
      RUBY
    end

    it 'does not register an offense for ambiguous single word' do
      expect_no_offenses(<<~RUBY)
        fill_in 'email', with: 'x'
      RUBY
    end

    it 'does not register an offense for non-string locator' do
      expect_no_offenses(<<~RUBY)
        fill_in field, with: 'x'
      RUBY
    end
  end
end
