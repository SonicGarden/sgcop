require 'spec_helper'

describe RuboCop::Cop::Sgcop::Rspec::NoMethodCallInExpectation do
  subject(:cop) { RuboCop::Cop::Sgcop::Rspec::NoMethodCallInExpectation.new(config) }
  let(:config) do
    RuboCop::Config.new(
      'Sgcop/Rspec/NoMethodCallInExpectation' => {
        'TargetMatchers' => %w[have_content have_text have_css have_selector eq include],
        'AllowedPatterns' => ['^I18n\.t$', '^I18n\.l$'],
      }
    )
  end

  context 'when using method calls in have_content' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(page).to have_content(project.title)
                                     ^^^^^^^^^^^^^ Use literal values instead of method calls in expectations. Use "have_content" with literal values.
      RUBY
    end
  end

  context 'when using method calls in have_text' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(page).to have_text(user.name)
                                  ^^^^^^^^^ Use literal values instead of method calls in expectations. Use "have_text" with literal values.
      RUBY
    end
  end

  context 'when using method calls in eq' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(result).to eq(calculate_value())
                             ^^^^^^^^^^^^^^^^^ Use literal values instead of method calls in expectations. Use "eq" with literal values.
      RUBY
    end
  end

  context 'when using method calls in include' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(array).to include(item.value)
                                 ^^^^^^^^^^ Use literal values instead of method calls in expectations. Use "include" with literal values.
      RUBY
    end
  end

  context 'when using instance variable method calls' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(page).to have_content(@project.title)
                                     ^^^^^^^^^^^^^^ Use literal values instead of method calls in expectations. Use "have_content" with literal values.
      RUBY
    end
  end

  context 'when using local variables' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(result).to eq(expected_value)
      RUBY
    end
  end

  context 'when using instance variables' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content(@project)
      RUBY
    end
  end

  context 'when using constants' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content(PROJECT_TITLE)
      RUBY
    end
  end

  context 'when using literal string' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content("プロジェクトタイトル")
      RUBY
    end
  end

  context 'when using literal number' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(count).to eq(5)
      RUBY
    end
  end

  context 'when using literal symbol' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(status).to eq(:success)
      RUBY
    end
  end

  context 'when using literal boolean' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(result).to eq(true)
        expect(flag).to eq(false)
      RUBY
    end
  end

  context 'when using nil' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(value).to eq(nil)
      RUBY
    end
  end

  context 'when using literal array' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(items).to eq(["item1", "item2"])
      RUBY
    end
  end

  context 'when using array with variables' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(items).to eq([item1, item2, @item3])
      RUBY
    end
  end

  context 'when using literal hash' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(data).to eq({ name: "Test", value: 123 })
      RUBY
    end
  end

  context 'when using hash with variables' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(data).to eq({ name: username, value: count })
      RUBY
    end
  end

  context 'when using regexp' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(text).to match(/pattern/)
      RUBY
    end
  end

  context 'when using I18n.t' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content(I18n.t('projects.title'))
      RUBY
    end

    it 'does not register an offense with have_selector text option' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_selector 'h1', text: I18n.t('text.title')
      RUBY
    end
  end

  context 'when using I18n.l' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content(I18n.l(date))
      RUBY
    end
  end

  context 'when using URL helpers' do
    let(:config) do
      RuboCop::Config.new(
        'Sgcop/Rspec/NoMethodCallInExpectation' => {
          'TargetMatchers' => %w[have_content eq have_selector],
          'AllowedPatterns' => ['_path$', '_url$'],
        }
      )
    end

    it 'does not register an offense for _path helpers' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content(root_path)
        expect(current_path).to eq(users_path)
      RUBY
    end

    it 'does not register an offense for _url helpers' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content(root_url)
        expect(location).to eq(users_url)
      RUBY
    end

    it 'does not register an offense for URL helpers inside string interpolation' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_selector "a[href='\#{root_path}']"
      RUBY
    end

    it 'does not register an offense for multiple URL helpers inside string interpolation' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_selector "a[href='\#{user_path(1)}'][data-id='\#{item_path(2)}']"
      RUBY
    end

    it 'does not register an offense for variables inside string interpolation' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_selector "a[href='\#{path_var}'][data-value='\#{value}']"
      RUBY
    end

    it 'registers an offense for method calls in string interpolation' do
      expect_offense(<<~RUBY)
        expect(page).to have_selector "a[href='\#{user.path}']"
                                      ^^^^^^^^^^^^^^^^^^^^^^^^ Use literal values instead of method calls in expectations. Use "have_selector" with literal values.
      RUBY
    end
  end

  context 'when using non-configured matcher' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(result).to be_truthy
        expect(page).to have_link(link.text)
      RUBY
    end
  end

  context 'when using multiple arguments' do
    it 'registers offenses for method call arguments only' do
      expect_offense(<<~RUBY)
        expect(page).to have_content("Fixed Text", user.name)
                                                   ^^^^^^^^^ Use literal values instead of method calls in expectations. Use "have_content" with literal values.
      RUBY
    end

    it 'does not register offenses for variable arguments' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content("Fixed Text", dynamic_text)
      RUBY
    end
  end

  context 'when custom configuration' do
    let(:config) do
      RuboCop::Config.new(
        'Sgcop/Rspec/NoMethodCallInExpectation' => {
          'TargetMatchers' => %w[eq],
          'AllowedPatterns' => ['^helper_method$'],
        }
      )
    end

    it 'only checks configured matchers' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content(project.name)
      RUBY

      expect_offense(<<~RUBY)
        expect(result).to eq(user.value)
                             ^^^^^^^^^^ Use literal values instead of method calls in expectations. Use "eq" with literal values.
      RUBY
    end

    it 'allows configured methods' do
      expect_no_offenses(<<~RUBY)
        expect(page).to eq(helper_method('key'))
      RUBY
    end
  end
end
