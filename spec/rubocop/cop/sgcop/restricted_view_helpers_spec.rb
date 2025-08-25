require 'spec_helper'

describe RuboCop::Cop::Sgcop::RestrictedViewHelpers do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new(
      'Sgcop/RestrictedViewHelpers' => {
        'RestrictedMethods' => {
          'simple_format' => 'cssで改行反映されるようにしてください。',
          'raw' => 'sanitizeメソッドを使用してください。',
        },
      }
    )
  end

  it 'simple_formatが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      def some_method
        simple_format(text)
        ^^^^^^^^^^^^^^^^^^^ cssで改行反映されるようにしてください。
      end
    RUBY
  end

  it 'rawが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      def some_method
        raw(html_content)
        ^^^^^^^^^^^^^^^^^ sanitizeメソッドを使用してください。
      end
    RUBY
  end

  it '複数の禁止メソッドが使用された場合は全て警告される' do
    expect_offense(<<~RUBY)
      def some_method
        simple_format(text)
        ^^^^^^^^^^^^^^^^^^^ cssで改行反映されるようにしてください。
        raw(html_content)
        ^^^^^^^^^^^^^^^^^ sanitizeメソッドを使用してください。
      end
    RUBY
  end

  it '禁止メソッドがレシーバ付きで呼ばれた場合は警告されない' do
    expect_no_offenses(<<~RUBY)
      def some_method
        helper.simple_format(text)
        other.raw(html_content)
      end
    RUBY
  end

  it '禁止されていないメソッドは警告されない' do
    expect_no_offenses(<<~RUBY)
      def some_method
        sanitize(html_content)
        content_tag(:p, text)
      end
    RUBY
  end

  context '設定が空の場合' do
    let(:config) do
      RuboCop::Config.new(
        'Sgcop/RestrictedViewHelpers' => {
          'RestrictedMethods' => {},
        }
      )
    end

    it '警告が発生しない' do
      expect_no_offenses(<<~RUBY)
        def some_method
          simple_format(text)
          raw(html_content)
        end
      RUBY
    end
  end
end
