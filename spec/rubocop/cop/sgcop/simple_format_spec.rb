require 'spec_helper'

describe RuboCop::Cop::Sgcop::SimpleFormat do
  subject(:cop) { RuboCop::Cop::Sgcop::SimpleFormat.new }

  it 'simple_formatに変数が直接渡されていたら警告' do
    expect_offense(<<~RUBY)
      def html_format(text)
        simple_format(text)
        ^^^^^^^^^^^^^^^^^^^ simple_format does not escape HTML tags.
      end
    RUBY
  end

  it 'simple_formatにオブジェクトのメソッドが渡されていたら警告' do
    expect_offense(<<~RUBY)
      def html_format(object)
        simple_format(object.body)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ simple_format does not escape HTML tags.
      end
    RUBY
  end

  it 'simple_formatにメソッドの返り値が渡されていたら警告なし' do
    expect_no_offenses(<<~RUBY)
      def html_format(text)
        simple_format(h(text))
      end
    RUBY
  end

  it 'haml-lintでsimple_formatにローカス変数が渡されていたら警告' do
    expect_offense(<<~RUBY)
      haml_lint_puts_0 # h1
      simple_format(text)
      ^^^^^^^^^^^^^^^^^^^ simple_format does not escape HTML tags.
      _haml_lint_puts_1 # h1/
    RUBY
  end

  it 'haml-lintでsimple_formatにインスタンス変数が渡されていたら警告' do
    expect_offense(<<~RUBY)
      haml_lint_puts_0 # h1
      simple_format(@text)
      ^^^^^^^^^^^^^^^^^^^^ simple_format does not escape HTML tags.
      _haml_lint_puts_1 # h1/
    RUBY
  end

  it 'haml-lintでsimple_formatにインスタンス変数のメソッドが渡されていたら警告' do
    expect_offense(<<~RUBY)
      haml_lint_puts_0 # h1
      simple_format(@object.body)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ simple_format does not escape HTML tags.
      _haml_lint_puts_1 # h1/
    RUBY
  end

  it 'haml-lintでsimple_formatにヘルパ経由のローカル変数が渡されていたら警告なし' do
    expect_no_offenses(<<~RUBY)
      haml_lint_puts_0 # h1
      simple_format(h(text))
      _haml_lint_puts_1 # h1/
    RUBY
  end

  it 'haml-lintでsimple_formatにヘルパ経由のインスタンス変数が渡されていたら警告なし' do
    expect_no_offenses(<<~RUBY)
      haml_lint_puts_0 # h1
      simple_format(h(@text))
      _haml_lint_puts_1 # h1/
    RUBY
  end

  it 'haml-lintでsimple_formatにヘルパ経由のインスタンス変数のメソッドが渡されていたら警告なし' do
    expect_no_offenses(<<~RUBY)
      haml_lint_puts_0 # h1
      simple_format(h(@object.body))
      _haml_lint_puts_1 # h1/
    RUBY
  end
end
