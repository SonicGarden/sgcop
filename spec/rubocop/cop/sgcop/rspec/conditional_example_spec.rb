require 'spec_helper'

describe RuboCop::Cop::Sgcop::Rspec::ConditionalExample do
  subject(:cop) { RuboCop::Cop::Sgcop::Rspec::ConditionalExample.new }

  context 'when expect has if modifier' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(page).to have_content(project.description) if project.description.present?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ConditionalExample: Avoid conditional expectations. Always assert expectations unconditionally.
      RUBY
    end
  end

  context 'when expect has unless modifier' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(result).to be_success unless error_occurred
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ConditionalExample: Avoid conditional expectations. Always assert expectations unconditionally.
      RUBY
    end
  end

  context 'when expect is inside if block without else' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if condition
        ^^^^^^^^^^^^ Sgcop/Rspec/ConditionalExample: Avoid conditional expectations. Always assert expectations unconditionally.
          expect(value).to eq(expected)
        end
      RUBY
    end
  end

  context 'when multiple expects are inside if block without else' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if condition
        ^^^^^^^^^^^^ Sgcop/Rspec/ConditionalExample: Avoid conditional expectations. Always assert expectations unconditionally.
          expect(value1).to eq(expected1)
          expect(value2).to eq(expected2)
        end
      RUBY
    end
  end

  context 'when expect is inside unless block without else' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        unless error_occurred
        ^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ConditionalExample: Avoid conditional expectations. Always assert expectations unconditionally.
          expect(result).to be_success
        end
      RUBY
    end
  end

  context 'when expect is inside if block with else' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        if condition
          expect(value).to eq(expected1)
        else
          expect(value).to eq(expected2)
        end
      RUBY
    end
  end

  context 'when expect is inside if block with elsif and else' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        if condition1
          expect(value).to eq(expected1)
        elsif condition2
          expect(value).to eq(expected2)
        else
          expect(value).to eq(expected3)
        end
      RUBY
    end
  end

  context 'when expect is used without conditions' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content('Hello')
      RUBY
    end
  end

  context 'when expect is used with method chain' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content('Hello').and have_link('Click')
      RUBY
    end
  end

  context 'when if block contains non-expect code' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        if condition
          visit home_path
          click_on 'Submit'
        end
      RUBY
    end
  end

  context 'when if block contains expect with other code' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if condition
        ^^^^^^^^^^^^ Sgcop/Rspec/ConditionalExample: Avoid conditional expectations. Always assert expectations unconditionally.
          visit home_path
          expect(page).to have_content('Success')
        end
      RUBY
    end
  end

  context 'when condition check is not about expect' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        result = perform_action if condition
      RUBY
    end
  end
end
