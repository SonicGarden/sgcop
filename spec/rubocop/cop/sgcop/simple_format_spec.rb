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

  it 'simple_formatにエスケープメソッドの結果が渡されていたら警告なし' do
    expect_no_offenses(<<~RUBY)
      simple_format(h(text))
    RUBY
  end

  it 'simple_formatにエスケープメソッド以外の結果が渡されていたら警告' do
    expect_offense(<<~RUBY)
      simple_format(t(text))
      ^^^^^^^^^^^^^^^^^^^^^^ simple_format does not escape HTML tags.
    RUBY
  end

  it 'simple_formatにインスタンス変数が渡されていたら警告' do
    expect_offense(<<~RUBY)
      simple_format(@object)
      ^^^^^^^^^^^^^^^^^^^^^^ simple_format does not escape HTML tags.
    RUBY
  end

  it 'simple_formatにインスタンス変数のメソッドが渡されていたら警告' do
    expect_offense(<<~RUBY)
      simple_format(@object.body)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ simple_format does not escape HTML tags.
    RUBY
  end
end
