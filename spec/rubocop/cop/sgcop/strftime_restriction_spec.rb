require 'spec_helper'

describe RuboCop::Cop::Sgcop::StrftimeRestriction do
  subject(:cop) { described_class.new(config) }
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sgcop/StrftimeRestriction' => {} } }

  it 'Date.todayでstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      Date.today.strftime('%Y-%m-%d')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
    RUBY
  end

  it 'Time.nowでstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      Time.now.strftime('%H:%M:%S')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
    RUBY
  end

  it 'DateTime.nowでstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      DateTime.now.strftime('%Y年%m月%d日')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
    RUBY
  end

  it 'Time.currentでstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      Time.current.strftime('%Y/%m/%d')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
    RUBY
  end

  it 'Time.zoneでstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      Time.zone.now.strftime('%Y-%m-%d')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
    RUBY
  end

  it '変数に格納された日付オブジェクトでstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      def format_date
        date = Date.today
        date.strftime('%Y-%m-%d')
        ^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      end
    RUBY
  end

  it 'インスタンス変数の日付オブジェクトでstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      def format_date
        @created_at.strftime('%Y-%m-%d')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      end
    RUBY
  end

  it 'to_dateの結果でstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      '2024-01-01'.to_date.strftime('%B %d, %Y')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
    RUBY
  end

  it 'ActiveSupport::TimeWithZoneでstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      Time.zone.parse('2024-01-01').strftime('%Y-%m-%d')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
    RUBY
  end

  it '1.day.agoでstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      1.day.ago.strftime('%Y-%m-%d')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
    RUBY
  end

  it 'beginning_of_monthでstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      Date.today.beginning_of_month.strftime('%Y-%m')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
    RUBY
  end

  it 'I18n.lが使用されている場合は警告されない' do
    expect_no_offenses(<<~RUBY)
      I18n.l(Date.today, format: :long)
    RUBY
  end

  it 'I18n.localizeが使用されている場合は警告されない' do
    expect_no_offenses(<<~RUBY)
      I18n.localize(Time.now, format: :short)
    RUBY
  end

  it '日付オブジェクト以外でもstrftimeが使用された場合は警告される' do
    expect_offense(<<~RUBY)
      some_object.strftime('%Y-%m-%d')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
    RUBY
  end

  it '複数のstrftimeが使用された場合は全て警告される' do
    expect_offense(<<~RUBY)
      def format_dates
        Date.today.strftime('%Y-%m-%d')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
        Time.now.strftime('%H:%M:%S')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
        @updated_at.strftime('%Y年%m月%d日')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      end
    RUBY
  end

  context '許可されたパターンの場合' do
    let(:cop_config) { { 'Sgcop/StrftimeRestriction' => { 'AllowedPatterns' => ['%a', '%A', '%w'] } } }
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

    it '許可されていないパターンは警告される' do
      expect_offense(<<~RUBY)
        Date.today.strftime('%Y-%m-%d')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end

    it '引数が動的な場合は警告される' do
      expect_offense(<<~RUBY)
        format = '%a'
        Date.today.strftime(format)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end
  end

  context 'AllowedPatternsが設定されていない場合' do
    it '%aパターンも警告される' do
      expect_offense(<<~RUBY)
        Date.today.strftime('%a')
        ^^^^^^^^^^^^^^^^^^^^^^^^^ strftimeではなくI18n.lを使用してローカライズしてください。
      RUBY
    end
  end
end
