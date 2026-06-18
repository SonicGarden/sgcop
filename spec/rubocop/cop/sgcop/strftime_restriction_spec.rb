require 'spec_helper'

describe RuboCop::Cop::Sgcop::StrftimeRestriction do
  subject(:cop) { described_class.new(config) }
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sgcop/StrftimeRestriction' => {} } }

  context '指定子と区切り記号のみで構成される場合は許容される' do
    it 'ハイフン区切り（%Y-%m-%d）は警告されない' do
      expect_no_offenses(<<~RUBY)
        Date.today.strftime('%Y-%m-%d')
      RUBY
    end

    it 'スラッシュ区切り（%Y/%m/%d）は警告されない' do
      expect_no_offenses(<<~RUBY)
        Time.current.strftime('%Y/%m/%d')
      RUBY
    end

    it 'コロン区切り（%H:%M:%S）は警告されない' do
      expect_no_offenses(<<~RUBY)
        Time.now.strftime('%H:%M:%S')
      RUBY
    end

    it 'ドット区切り（%Y.%m.%d）は警告されない' do
      expect_no_offenses(<<~RUBY)
        Date.today.strftime('%Y.%m.%d')
      RUBY
    end

    it '区切りなしの指定子連続（%Y%m%d）は警告されない' do
      expect_no_offenses(<<~RUBY)
        Date.today.strftime('%Y%m%d')
      RUBY
    end

    it '空白区切り（%H %M）は警告されない' do
      expect_no_offenses(<<~RUBY)
        Time.now.strftime('%H %M')
      RUBY
    end

    it '%%エスケープを含む（%% %Y）は警告されない' do
      expect_no_offenses(<<~RUBY)
        Time.now.strftime('%% %Y')
      RUBY
    end
  end

  context '曜日関連の指定子単体は設定なしでも許容される' do
    it '%aパターンは警告されない' do
      expect_no_offenses(<<~RUBY)
        Date.today.strftime('%a')
      RUBY
    end

    it '%Aパターンは警告されない' do
      expect_no_offenses(<<~RUBY)
        Time.now.strftime('%A')
      RUBY
    end

    it '%wパターンは警告されない' do
      expect_no_offenses(<<~RUBY)
        DateTime.now.strftime('%w')
      RUBY
    end
  end

  context 'フラグ・幅・修飾子付きの指定子は許容される' do
    it 'フラグ付き（%-d）は警告されない' do
      expect_no_offenses(<<~RUBY)
        Date.today.strftime('%-d')
      RUBY
    end

    it '幅付き（%3N）は警告されない' do
      expect_no_offenses(<<~RUBY)
        Time.now.strftime('%3N')
      RUBY
    end

    it 'コロン形式のタイムゾーン（%::z）は警告されない' do
      expect_no_offenses(<<~RUBY)
        Time.now.strftime('%::z')
      RUBY
    end
  end

  context 'リテラル単語が混ざる場合は警告される' do
    it '日本語リテラル（%Y年%m月%d日）は警告される' do
      expect_offense(<<~RUBY)
        DateTime.now.strftime('%Y年%m月%d日')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end

    it '日本語1文字混在（%Y年）は警告される' do
      expect_offense(<<~RUBY)
        Date.today.strftime('%Y年')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end

    it 'カンマと英字リテラル（%B %d, %Y）は警告される' do
      expect_offense(<<~RUBY)
        '2024-01-01'.to_date.strftime('%B %d, %Y')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end

    it '英単語リテラル（Today is %A）は警告される' do
      expect_offense(<<~RUBY)
        Time.now.strftime('Today is %A')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end
  end

  context 'レシーバの種類を問わずリテラル混在は警告される' do
    it 'インスタンス変数の日付オブジェクト' do
      expect_offense(<<~RUBY)
        @created_at.strftime('%Y年%m月%d日')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end

    it 'メソッドチェーンの結果' do
      expect_offense(<<~RUBY)
        Date.today.beginning_of_month.strftime('%Y年%m月')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end

    it '日付オブジェクト以外でも警告される' do
      expect_offense(<<~RUBY)
        some_object.strftime('%Y年%m月%d日')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end
  end

  context '動的・引数なしの場合は警告される' do
    it '引数が動的（変数）な場合は警告される' do
      expect_offense(<<~RUBY)
        format = '%Y年%m月%d日'
        Date.today.strftime(format)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end

    it '引数なしの場合は警告される' do
      expect_offense(<<~RUBY)
        Date.today.strftime
        ^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end
  end

  context 'リテラル混在と指定子のみが混在する場合' do
    it 'リテラル入りのものだけ警告される' do
      expect_offense(<<~RUBY)
        def format_dates
          Date.today.strftime('%Y-%m-%d')
          Time.now.strftime('%H:%M:%S')
          @updated_at.strftime('%Y年%m月%d日')
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
        end
      RUBY
    end
  end

  context 'I18n.lが使用されている場合は警告されない' do
    it 'I18n.l' do
      expect_no_offenses(<<~RUBY)
        I18n.l(Date.today, format: :long)
      RUBY
    end

    it 'I18n.localize' do
      expect_no_offenses(<<~RUBY)
        I18n.localize(Time.now, format: :short)
      RUBY
    end
  end

  context 'AllowedPatternsに完全一致を指定した場合（後方互換）' do
    let(:cop_config) { { 'Sgcop/StrftimeRestriction' => { 'AllowedPatterns' => ['%Y年%m月%d日'] } } }

    it '完全一致するリテラル入りフォーマットは警告されない' do
      expect_no_offenses(<<~RUBY)
        Date.today.strftime('%Y年%m月%d日')
      RUBY
    end

    it '一致しない別のリテラル入りフォーマットは警告される' do
      expect_offense(<<~RUBY)
        Date.today.strftime('%Y年%m月')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end
  end
end
