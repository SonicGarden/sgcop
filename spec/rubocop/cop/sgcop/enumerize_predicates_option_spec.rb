require 'spec_helper'

describe RuboCop::Cop::Sgcop::EnumerizePredicatesOption do
  subject(:cop) { described_class.new(config) }
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sgcop/EnumerizePredicatesOption' => { 'AllowWithPrefix' => allow_with_prefix } } }
  let(:allow_with_prefix) { false }

  context 'when AllowWithPrefix is false' do
    it 'registers an offense when using predicates: true' do
      expect_offense(<<~RUBY)
        enumerize :status, in: %w[active inactive], predicates: true
                                                    ^^^^^^^^^^^^^^^^ Do not use `predicates` option in `enumerize`.
      RUBY
    end

    it 'registers an offense when using predicates: false' do
      expect_offense(<<~RUBY)
        enumerize :status, in: %w[active inactive], predicates: false
                                                    ^^^^^^^^^^^^^^^^^ Do not use `predicates` option in `enumerize`.
      RUBY
    end

    it 'registers an offense when using predicates with prefix option' do
      expect_offense(<<~RUBY)
        enumerize :status, in: %w[active inactive], predicates: { prefix: true }
                                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `predicates` option in `enumerize`.
      RUBY
    end

    it 'registers an offense when using predicates with other hash options' do
      expect_offense(<<~RUBY)
        enumerize :status, in: %w[active inactive], predicates: { only: [:active] }
                                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `predicates` option in `enumerize`.
      RUBY
    end

    it 'registers an offense when using predicates in a class' do
      expect_offense(<<~RUBY)
        class User < ApplicationRecord
          enumerize :role, in: ROLES, predicates: true
                                      ^^^^^^^^^^^^^^^^ Do not use `predicates` option in `enumerize`.
        end
      RUBY
    end

    it 'does not register an offense when enumerize is used without predicates option' do
      expect_no_offenses(<<~RUBY)
        enumerize :status, in: %w[active inactive]
      RUBY
    end

    it 'does not register an offense when enumerize is used with other options' do
      expect_no_offenses(<<~RUBY)
        enumerize :status, in: %w[active inactive], scope: true
      RUBY
    end

    it 'does not register an offense for other method calls with predicates' do
      expect_no_offenses(<<~RUBY)
        some_method :param, predicates: true
      RUBY
    end
  end

  context 'when AllowWithPrefix is true' do
    let(:allow_with_prefix) { true }

    it 'registers an offense with message suggesting prefix when using predicates: true' do
      expect_offense(<<~RUBY)
        enumerize :status, in: %w[active inactive], predicates: true
                                                    ^^^^^^^^^^^^^^^^ Use `predicates: { prefix: true }` instead of `predicates: true`.
      RUBY
    end

    it 'registers an offense when using predicates: false' do
      expect_offense(<<~RUBY)
        enumerize :status, in: %w[active inactive], predicates: false
                                                    ^^^^^^^^^^^^^^^^^ Do not use `predicates` option in `enumerize`.
      RUBY
    end

    it 'does not register an offense when using predicates: { prefix: true }' do
      expect_no_offenses(<<~RUBY)
        enumerize :status, in: %w[active inactive], predicates: { prefix: true }
      RUBY
    end

    it 'registers an offense when using predicates with prefix: false' do
      expect_offense(<<~RUBY)
        enumerize :status, in: %w[active inactive], predicates: { prefix: false }
                                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `predicates` option in `enumerize`.
      RUBY
    end

    it 'registers an offense when using predicates with other hash options' do
      expect_offense(<<~RUBY)
        enumerize :status, in: %w[active inactive], predicates: { only: [:active] }
                                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `predicates` option in `enumerize`.
      RUBY
    end
  end
end
