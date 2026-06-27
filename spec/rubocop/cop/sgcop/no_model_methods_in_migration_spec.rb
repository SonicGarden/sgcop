require 'spec_helper'

describe RuboCop::Cop::Sgcop::NoModelMethodsInMigration do
  subject(:cop) { described_class.new(config) }
  let(:config) { RuboCop::Config.new(cop_config) }
  let(:cop_config) { { 'Sgcop/NoModelMethodsInMigration' => { 'AllowedConstants' => allowed_constants } } }
  let(:allowed_constants) { [] }

  it 'registers an offense for a model method call' do
    expect_offense(<<~RUBY)
      User.delete_all
      ^^^^^^^^^^^^^^^ Do not call model methods in migrations. Models change over time; use raw SQL or a rake task instead.
    RUBY
  end

  it 'registers an offense for a chained model method call' do
    expect_offense(<<~RUBY)
      Post.where(active: true).update_all(x: 1)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not call model methods in migrations. Models change over time; use raw SQL or a rake task instead.
    RUBY
  end

  it 'registers an offense for a namespaced model method call' do
    expect_offense(<<~RUBY)
      Foo::Bar.pluck(:id)
      ^^^^^^^^^^^^^^^^^^^ Do not call model methods in migrations. Models change over time; use raw SQL or a rake task instead.
    RUBY
  end

  it 'does not register an offense for ActiveRecord::Migration class declaration' do
    expect_no_offenses(<<~RUBY)
      class AddColumn < ActiveRecord::Migration[7.0]
      end
    RUBY
  end

  it 'does not register an offense for ActiveRecord::Base method calls' do
    expect_no_offenses(<<~RUBY)
      ActiveRecord::Base.send(:foo)
    RUBY
  end

  it 'does not register an offense for ActiveStorage framework constants' do
    expect_no_offenses(<<~RUBY)
      ActiveStorage::Blob.service
    RUBY
  end

  it 'registers an offense for a constant merely prefixed with an ignored name' do
    expect_offense(<<~RUBY)
      ActiveRecordModel.delete_all
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not call model methods in migrations. Models change over time; use raw SQL or a rake task instead.
    RUBY
  end

  it 'does not register an offense for method calls on a locally defined constant' do
    expect_no_offenses(<<~RUBY)
      KIND_LIST = %w[a b c]
      KIND_LIST.each do |kind|
        puts kind
      end
    RUBY
  end

  it 'registers an offense for Ruby built-in class method calls' do
    expect_offense(<<~RUBY)
      Time.current
      ^^^^^^^^^^^^ Do not call model methods in migrations. Models change over time; use raw SQL or a rake task instead.
    RUBY
  end

  context 'when the constant is allowed via AllowedConstants' do
    let(:allowed_constants) { ['User'] }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        User.delete_all
      RUBY
    end
  end
end
