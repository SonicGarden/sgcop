require 'spec_helper'

describe RuboCop::Cop::Sgcop::HashFetchDefault do
  subject(:cop) { RuboCop::Cop::Sgcop::HashFetchDefault.new }

  it 'registers an offense when using || with hash access' do
    expect_offense(<<~RUBY)
      batman[:is_evil] || true
      ^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/HashFetchDefault: Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.
    RUBY

    expect_correction(<<~RUBY)
      batman.fetch(:is_evil, true)
    RUBY
  end

  it 'registers an offense with method calls on hash' do
    expect_offense(<<~RUBY)
      config[:enabled] || false
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/HashFetchDefault: Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.
    RUBY

    expect_correction(<<~RUBY)
      config.fetch(:enabled, false)
    RUBY
  end

  it 'registers an offense with string keys' do
    expect_offense(<<~RUBY)
      params["value"] || "default"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/HashFetchDefault: Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.
    RUBY

    expect_correction(<<~RUBY)
      params.fetch("value", "default")
    RUBY
  end

  it 'registers an offense with complex default values' do
    expect_offense(<<~RUBY)
      options[:retries] || MAX_RETRIES
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/HashFetchDefault: Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.
    RUBY

    expect_correction(<<~RUBY)
      options.fetch(:retries, MAX_RETRIES)
    RUBY
  end

  it 'does not register an offense for non-hash access with ||' do
    expect_no_offenses(<<~RUBY)
      name || "Anonymous"
    RUBY
  end

  it 'does not register an offense for method calls without ||' do
    expect_no_offenses(<<~RUBY)
      batman[:is_evil]
    RUBY
  end

  it 'does not register an offense when already using fetch' do
    expect_no_offenses(<<~RUBY)
      batman.fetch(:is_evil, true)
    RUBY
  end
end
