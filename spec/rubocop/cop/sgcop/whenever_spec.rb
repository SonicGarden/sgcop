require 'spec_helper'

describe RuboCop::Cop::Sgcop::Whenever do
  subject(:cop) { RuboCop::Cop::Sgcop::Whenever.new }


  it '12時間表記は警告' do
    expect_offense(<<~RUBY)
      set :chronic_options, hours24: true

      every 1.day, at: '7:10 am' do
                   ^^^^^^^^^^^^^ Sgcop/Whenever: Use 24-hour clock to avoid errors.
      rake 'sgcop'
    end
    RUBY
  end

  it '24時間表記は警告無し' do
    expect_no_offenses(<<~RUBY)
      set :chronic_options, hours24: true

      every 1.day, at: '07:10' do
        rake 'sgcop'
      end
    RUBY
  end

  it 'オプション無効の場合は警告無し' do
    expect_no_offenses(<<~RUBY)
      every 1.day, at: '07:10' do
        rake 'sgcop'
      end
    RUBY
  end

  it 'cron表記は警告無し' do
    expect_no_offenses(<<~RUBY)
      set :chronic_options, hours24: true

      every '33 4 * * 1' do
        rake 'sgcop'
      end
    RUBY
  end

  it '変数指定の場合は警告無し' do
    expect_no_offenses(<<~RUBY)
      set :chronic_options, hours24: true

      start_time = '07:10'
      every :saturday, at: start_time do
        rake 'sgcop'
      end
    RUBY
  end
end
