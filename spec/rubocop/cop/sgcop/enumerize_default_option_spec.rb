require 'spec_helper'

describe RuboCop::Cop::Sgcop::EnumerizeDefaultOption do
  subject(:cop) { described_class.new }

  it 'registers an offense when using default option in enumerize' do
    expect_offense(<<~RUBY)
      enumerize :role, in: ROLES, default: :operator
                                  ^^^^^^^^^^^^^^^^^^ Sgcop/EnumerizeDefaultOption: Do not use `default` option in `enumerize`. Use database-level default values instead.
    RUBY
  end

  it 'registers an offense when using default option with other options' do
    expect_offense(<<~RUBY)
      enumerize :status, in: %w[active inactive], default: 'active', scope: true
                                                  ^^^^^^^^^^^^^^^^^ Sgcop/EnumerizeDefaultOption: Do not use `default` option in `enumerize`. Use database-level default values instead.
    RUBY
  end

  it 'registers an offense when using default option in class method call' do
    expect_offense(<<~RUBY)
      class User < ApplicationRecord
        enumerize :role, in: ROLES, default: :operator
                                    ^^^^^^^^^^^^^^^^^^ Sgcop/EnumerizeDefaultOption: Do not use `default` option in `enumerize`. Use database-level default values instead.
      end
    RUBY
  end

  it 'does not register an offense when enumerize is used without default option' do
    expect_no_offenses(<<~RUBY)
      enumerize :role, in: ROLES
    RUBY
  end

  it 'does not register an offense when enumerize is used with other options' do
    expect_no_offenses(<<~RUBY)
      enumerize :status, in: %w[active inactive], scope: true
    RUBY
  end

  it 'does not register an offense when enumerize is used without options' do
    expect_no_offenses(<<~RUBY)
      enumerize :role, in: ROLES
    RUBY
  end

  it 'does not register an offense for other method calls with default' do
    expect_no_offenses(<<~RUBY)
      some_method :param, default: :value
    RUBY
  end
end
