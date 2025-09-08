require 'spec_helper'

describe RuboCop::Cop::Sgcop::I18nLocalizeFormatString do
  subject(:cop) { described_class.new }

  context 'I18n.lメソッド' do
    it '文字列でフォーマットが指定された場合は警告される（日本語）' do
      expect_offense(<<~RUBY)
        I18n.l(Date.today, format: '%Y年%m月%d日')
                                   ^^^^^^^^^^^ Sgcop/I18nLocalizeFormatString: I18n.lのformatオプションには文字列ではなくシンボルを使用してください。ロケールファイルに定義してシンボルで参照することで、ロケールごとの切り替えが可能になります。
      RUBY
    end

    it '文字列でフォーマットが指定された場合は警告される（英語）' do
      expect_offense(<<~RUBY)
        I18n.l(Time.now, format: '%Y-%m-%d %H:%M:%S')
                                 ^^^^^^^^^^^^^^^^^^^ Sgcop/I18nLocalizeFormatString: I18n.lのformatオプションには文字列ではなくシンボルを使用してください。ロケールファイルに定義してシンボルで参照することで、ロケールごとの切り替えが可能になります。
      RUBY
    end

    it '空文字列でも警告される' do
      expect_offense(<<~RUBY)
        I18n.l(Date.today, format: '')
                                   ^^ Sgcop/I18nLocalizeFormatString: I18n.lのformatオプションには文字列ではなくシンボルを使用してください。ロケールファイルに定義してシンボルで参照することで、ロケールごとの切り替えが可能になります。
      RUBY
    end

    it 'シンボルでフォーマットが指定された場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        I18n.l(Date.today, format: :long)
      RUBY
    end

    it 'formatオプションがない場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        I18n.l(Date.today)
      RUBY
    end
  end

  context 'I18n.localizeメソッド' do
    it '文字列でフォーマットが指定された場合は警告される' do
      expect_offense(<<~RUBY)
        I18n.localize(Date.today, format: '%Y年%m月')
                                          ^^^^^^^^ Sgcop/I18nLocalizeFormatString: I18n.lのformatオプションには文字列ではなくシンボルを使用してください。ロケールファイルに定義してシンボルで参照することで、ロケールごとの切り替えが可能になります。
      RUBY
    end

    it 'シンボルでフォーマットが指定された場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        I18n.localize(Time.now, format: :short)
      RUBY
    end
  end

  context 'ビューヘルパーのlメソッド' do
    it '文字列でフォーマットが指定された場合は警告される（日本語）' do
      expect_offense(<<~RUBY)
        l(Date.today, format: '%Y年%m月%d日')
                              ^^^^^^^^^^^ Sgcop/I18nLocalizeFormatString: I18n.lのformatオプションには文字列ではなくシンボルを使用してください。ロケールファイルに定義してシンボルで参照することで、ロケールごとの切り替えが可能になります。
      RUBY
    end

    it '文字列でフォーマットが指定された場合は警告される（英語）' do
      expect_offense(<<~RUBY)
        l(Time.now, format: '%H:%M:%S')
                            ^^^^^^^^^^ Sgcop/I18nLocalizeFormatString: I18n.lのformatオプションには文字列ではなくシンボルを使用してください。ロケールファイルに定義してシンボルで参照することで、ロケールごとの切り替えが可能になります。
      RUBY
    end

    it 'シンボルでフォーマットが指定された場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        l(Date.today, format: :long)
      RUBY
    end
  end

  context 'ビューヘルパーのlocalizeメソッド' do
    it '文字列でフォーマットが指定された場合は警告される' do
      expect_offense(<<~RUBY)
        localize(DateTime.now, format: '%Y年%m月%d日 %H時')
                                       ^^^^^^^^^^^^^^^ Sgcop/I18nLocalizeFormatString: I18n.lのformatオプションには文字列ではなくシンボルを使用してください。ロケールファイルに定義してシンボルで参照することで、ロケールごとの切り替えが可能になります。
      RUBY
    end

    it 'シンボルでフォーマットが指定された場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        localize(Time.zone.now, format: :custom)
      RUBY
    end
  end

  context '複雑なパターン' do
    it '変数を使用したフォーマットは警告されない' do
      expect_no_offenses(<<~RUBY)
        format_string = '%Y年%m月%d日'
        I18n.l(Date.today, format: format_string)
      RUBY
    end

    it 'formatオプションがない場合は警告されない' do
      expect_no_offenses(<<~RUBY)
        I18n.l(Date.today)
      RUBY
    end
  end

  context '他のメソッド' do
    it 'I18n.tメソッドは対象外' do
      expect_no_offenses(<<~RUBY)
        I18n.t('date.formats.long', format: '%Y年%m月%d日')
      RUBY
    end

    it 'strftimeメソッドは対象外' do
      expect_no_offenses(<<~RUBY)
        Date.today.strftime('%Y年%m月%d日')
      RUBY
    end

    it 'レシーバーがあるlメソッドは対象外' do
      expect_no_offenses(<<~RUBY)
        helper.l(Date.today, format: '%Y年%m月%d日')
      RUBY
    end
  end
end
