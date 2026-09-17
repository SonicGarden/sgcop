require 'spec_helper'

describe RuboCop::Cop::Sgcop::TimeZoneLocal, :config do
  context '違反を検出する場合' do
    it '5引数のTime.zone.localを検出する' do
      expect_offense(<<~RUBY)
        Time.zone.local(2026, 9, 16, 10, 0)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Time.zone.localではなく日時文字列の.in_time_zoneを使用してください。
      RUBY

      expect_correction(<<~RUBY)
        '2026-09-16 10:00:00'.in_time_zone
      RUBY
    end

    it '6引数のTime.zone.localを検出する' do
      expect_offense(<<~RUBY)
        Time.zone.local(2026, 9, 16, 10, 0, 30)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Time.zone.localではなく日時文字列の.in_time_zoneを使用してください。
      RUBY

      expect_correction(<<~RUBY)
        '2026-09-16 10:00:30'.in_time_zone
      RUBY
    end

    it '4引数のTime.zone.localを検出する' do
      expect_offense(<<~RUBY)
        Time.zone.local(2026, 9, 16, 10)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Time.zone.localではなく日時文字列の.in_time_zoneを使用してください。
      RUBY

      expect_correction(<<~RUBY)
        '2026-09-16 10:00:00'.in_time_zone
      RUBY
    end

    it '3引数のTime.zone.localを検出する' do
      expect_offense(<<~RUBY)
        Time.zone.local(2026, 9, 16)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Time.zone.localではなく日時文字列の.in_time_zoneを使用してください。
      RUBY

      expect_correction(<<~RUBY)
        '2026-09-16 00:00:00'.in_time_zone
      RUBY
    end

    it 'ゼロ埋めが必要な値を正しく変換する' do
      expect_offense(<<~RUBY)
        Time.zone.local(2026, 1, 2, 3, 4, 5)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Time.zone.localではなく日時文字列の.in_time_zoneを使用してください。
      RUBY

      expect_correction(<<~RUBY)
        '2026-01-02 03:04:05'.in_time_zone
      RUBY
    end

    it '::Time前置でも検出する' do
      expect_offense(<<~RUBY)
        ::Time.zone.local(2026, 9, 16)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Time.zone.localではなく日時文字列の.in_time_zoneを使用してください。
      RUBY

      expect_correction(<<~RUBY)
        '2026-09-16 00:00:00'.in_time_zone
      RUBY
    end

    it 'メソッドチェーンの場合はsendノードのみ置換する' do
      expect_offense(<<~RUBY)
        Time.zone.local(2026, 9, 16).to_date
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Time.zone.localではなく日時文字列の.in_time_zoneを使用してください。
      RUBY

      expect_correction(<<~RUBY)
        '2026-09-16 00:00:00'.in_time_zone.to_date
      RUBY
    end
  end

  context '対象外の場合' do
    it '変数を含む場合は検出しない' do
      expect_no_offenses(<<~RUBY)
        Time.zone.local(year, 9, 16)
      RUBY
    end

    it '式を含む場合は検出しない' do
      expect_no_offenses(<<~RUBY)
        Time.zone.local(2026, month, 1)
      RUBY
    end

    it '1引数は検出しない' do
      expect_no_offenses(<<~RUBY)
        Time.zone.local(2026)
      RUBY
    end

    it '2引数は検出しない' do
      expect_no_offenses(<<~RUBY)
        Time.zone.local(2026, 9)
      RUBY
    end

    it '7引数(usec)は検出しない' do
      expect_no_offenses(<<~RUBY)
        Time.zone.local(2026, 9, 16, 10, 0, 0, 500_000)
      RUBY
    end

    it 'Time.zone.parseは検出しない' do
      expect_no_offenses(<<~RUBY)
        Time.zone.parse('2026-09-16')
      RUBY
    end

    it 'Time.zone.nowは検出しない' do
      expect_no_offenses(<<~RUBY)
        Time.zone.now
      RUBY
    end

    it 'Time.zone.todayは検出しない' do
      expect_no_offenses(<<~RUBY)
        Time.zone.today
      RUBY
    end

    it 'Time.localは検出しない' do
      expect_no_offenses(<<~RUBY)
        Time.local(2026, 9, 16)
      RUBY
    end

    it 'Time.nowは検出しない' do
      expect_no_offenses(<<~RUBY)
        Time.now
      RUBY
    end

    it '既に正しい形は検出しない' do
      expect_no_offenses(<<~RUBY)
        '2026-09-16 10:00:00'.in_time_zone
      RUBY
    end
  end
end
