require 'spec_helper'

describe RuboCop::Cop::Sgcop::Rspec::NoVariableExpectation do
  subject(:cop) { RuboCop::Cop::Sgcop::Rspec::NoVariableExpectation.new(config) }
  let(:config) do
    RuboCop::Config.new(
      'Sgcop/Rspec/NoVariableExpectation' => {
        'TargetMatchers' => %w[have_content have_text have_css have_selector eq include],
        'AllowedPatterns' => ['^I18n\.t$', '^I18n\.l$'],
      }
    )
  end

  context 'when using variables in have_content' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(page).to have_content(project.title)
                                     ^^^^^^^^^^^^^ Use literal values instead of variables in expectations. Use "have_content" with literal values.
      RUBY
    end
  end

  context 'when using variables in have_text' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(page).to have_text(user.name)
                                  ^^^^^^^^^ Use literal values instead of variables in expectations. Use "have_text" with literal values.
      RUBY
    end
  end

  context 'when using variables in eq' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(result).to eq(expected_value)
                             ^^^^^^^^^^^^^^ Use literal values instead of variables in expectations. Use "eq" with literal values.
      RUBY
    end
  end

  context 'when using variables in include' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(array).to include(item)
                                 ^^^^ Use literal values instead of variables in expectations. Use "include" with literal values.
      RUBY
    end
  end

  context 'when using instance variables' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(page).to have_content(@project.title)
                                     ^^^^^^^^^^^^^^ Use literal values instead of variables in expectations. Use "have_content" with literal values.
      RUBY
    end
  end

  context 'when using constants' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        expect(page).to have_content(PROJECT_TITLE)
                                     ^^^^^^^^^^^^^ Use literal values instead of variables in expectations. Use "have_content" with literal values.
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

  context 'when using literal hash' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(data).to eq({ name: "Test", value: 123 })
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
        'Sgcop/Rspec/NoVariableExpectation' => {
          'TargetMatchers' => %w[have_content eq],
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
  end

  context 'when using non-configured matcher' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        expect(result).to be_truthy
        expect(page).to have_link(link_text)
      RUBY
    end
  end

  context 'when using multiple arguments' do
    it 'registers offenses for variable arguments only' do
      expect_offense(<<~RUBY)
        expect(page).to have_content("Fixed Text", dynamic_text)
                                                   ^^^^^^^^^^^^ Use literal values instead of variables in expectations. Use "have_content" with literal values.
      RUBY
    end
  end

  context 'when custom configuration' do
    let(:config) do
      RuboCop::Config.new(
        'Sgcop/Rspec/NoVariableExpectation' => {
          'TargetMatchers' => %w[eq],
          'AllowedPatterns' => ['^helper_method$'],
        }
      )
    end

    it 'only checks configured matchers' do
      expect_no_offenses(<<~RUBY)
        expect(page).to have_content(variable)
      RUBY

      expect_offense(<<~RUBY)
        expect(result).to eq(variable)
                             ^^^^^^^^ Use literal values instead of variables in expectations. Use "eq" with literal values.
      RUBY
    end

    it 'allows configured methods' do
      expect_no_offenses(<<~RUBY)
        expect(page).to eq(helper_method('key'))
      RUBY
    end
  end
end
