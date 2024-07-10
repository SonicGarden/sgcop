require 'spec_helper'

describe RuboCop::Cop::Sgcop::TransactionRequiresNew do
  subject(:cop) { described_class.new }

  it 'registers an offense for a transaction block raising ActiveRecord::Rollback directly without `requires_new: true`' do
    expect_offense(<<~RUBY)
      ActiveRecord::Base.transaction do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/TransactionRequiresNew: Use `requires_new: true` with `transaction` when `ActiveRecord::Rollback` is raised inside the block.
        raise ActiveRecord::Rollback
      end
    RUBY
  end

  it 'registers an offense for a shorthand transaction block raising ActiveRecord::Rollback directly without `requires_new: true`' do
    expect_offense(<<~RUBY)
      transaction do
      ^^^^^^^^^^^ Sgcop/TransactionRequiresNew: Use `requires_new: true` with `transaction` when `ActiveRecord::Rollback` is raised inside the block.
        raise ActiveRecord::Rollback
      end
    RUBY
  end

  it 'registers an offense for a transaction block conditionally raising ActiveRecord::Rollback without `requires_new: true`' do
    expect_offense(<<~RUBY)
      transaction do
      ^^^^^^^^^^^ Sgcop/TransactionRequiresNew: Use `requires_new: true` with `transaction` when `ActiveRecord::Rollback` is raised inside the block.
        res = save
        raise ActiveRecord::Rollback unless res
      end
    RUBY
  end

  it 'does not register an offense for a transaction block with `requires_new: true` raising ActiveRecord::Rollback directly' do
    expect_no_offenses(<<~RUBY)
      ActiveRecord::Base.transaction(requires_new: true) do
        raise ActiveRecord::Rollback
      end
    RUBY
  end

  it 'does not register an offense for a transaction block with `requires_new: true` conditionally raising ActiveRecord::Rollback' do
    expect_no_offenses(<<~RUBY)
      transaction(requires_new: true) do
        res = save
        raise ActiveRecord::Rollback unless res
      end
    RUBY
  end
end
