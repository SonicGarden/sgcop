require 'spec_helper'

describe RuboCop::Cop::Sgcop::NoLoopedPerformLater do
  subject(:cop) { described_class.new }

  it 'registers an offense for perform_later inside each block with braces' do
    expect_offense(<<~RUBY)
      users.each { |u| NotifyJob.perform_later(u) }
                       ^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NoLoopedPerformLater: Avoid calling `perform_later` one-by-one inside a loop. Use `perform_all_later` to enqueue jobs in bulk.
    RUBY
  end

  it 'registers an offense for perform_later inside each block with do/end' do
    expect_offense(<<~RUBY)
      users.each do |u|
        NotifyJob.perform_later(u)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NoLoopedPerformLater: Avoid calling `perform_later` one-by-one inside a loop. Use `perform_all_later` to enqueue jobs in bulk.
      end
    RUBY
  end

  it 'registers an offense for perform_later inside map block' do
    expect_offense(<<~RUBY)
      records.map { |r| ProcessJob.perform_later(r.id) }
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NoLoopedPerformLater: Avoid calling `perform_later` one-by-one inside a loop. Use `perform_all_later` to enqueue jobs in bulk.
    RUBY
  end

  it 'does not register an offense for perform_all_later' do
    expect_no_offenses(<<~RUBY)
      users.each { |u| NotifyJob.perform_all_later(u) }
    RUBY
  end

  it 'does not register an offense for perform_later outside a loop' do
    expect_no_offenses(<<~RUBY)
      NotifyJob.perform_later(user)
    RUBY
  end

  it 'does not register an offense when the receiver is not a constant' do
    expect_no_offenses(<<~RUBY)
      items.each { |i| job.perform_later }
    RUBY
  end

  it 'does not register an offense for perform_later inside a for loop' do
    expect_no_offenses(<<~RUBY)
      for u in users
        NotifyJob.perform_later(u)
      end
    RUBY
  end

  it 'does not register an offense for perform_later inside a while loop' do
    expect_no_offenses(<<~RUBY)
      while user = users.pop
        NotifyJob.perform_later(user)
      end
    RUBY
  end
end
