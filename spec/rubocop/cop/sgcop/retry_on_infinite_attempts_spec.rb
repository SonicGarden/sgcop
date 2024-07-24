require 'spec_helper'

describe RuboCop::Cop::Sgcop::RetryOnInfiniteAttempts do
  subject(:cop) { described_class.new }

  it 'registers an offense when using Float::INFINITY for attempts' do
    expect_offense(<<~RUBY)
      retry_on StandardError, wait: :polynomially_longer, attempts: Float::INFINITY
                                                          ^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/RetryOnInfiniteAttempts: Avoid using `Float::INFINITY` or `:unlimited` for attempts in `retry_on` method.
    RUBY
  end

  it 'registers an offense when using :unlimited for attempts' do
    expect_offense(<<~RUBY)
      TestJob.retry_on TestError, wait: :polynomially_longer, attempts: :unlimited
                                                              ^^^^^^^^^^^^^^^^^^^^ Sgcop/RetryOnInfiniteAttempts: Avoid using `Float::INFINITY` or `:unlimited` for attempts in `retry_on` method.
    RUBY
  end

  it 'does not register an offense for finite attempts' do
    expect_no_offenses(<<~RUBY)
      retry_on StandardError, wait: :polynomially_longer, attempts: 3
    RUBY
  end
end
