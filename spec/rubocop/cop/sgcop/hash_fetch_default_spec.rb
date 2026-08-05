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

  it 'does not register an offense for integer index access (likely Array/String)' do
    expect_no_offenses(<<~RUBY)
      array[0] || "default"
    RUBY
  end

  it 'does not register an offense for range access (likely String/Array slice)' do
    expect_no_offenses(<<~RUBY)
      str[0..3] || "default"
    RUBY
  end

  it 'does not register an offense for multi-argument access (likely String#[])' do
    expect_no_offenses(<<~RUBY)
      str[0, 3] || "default"
    RUBY
  end

  it 'does not register an offense for variable key access (cannot tell if it is a Hash)' do
    expect_no_offenses(<<~RUBY)
      obj[index] || "default"
    RUBY
  end

  it 'does not register an offense for method call key access' do
    expect_no_offenses(<<~RUBY)
      obj[key_method] || "default"
    RUBY
  end

  it 'does not register an offense for a multi-key fallback chain' do
    expect_no_offenses(<<~RUBY)
      media_box = page[:CropBox] || page[:MediaBox] || [0, 0, 595.3, 841.9]
    RUBY
  end

  it 'does not register an offense for a two-element hash access chain' do
    expect_no_offenses(<<~RUBY)
      a[:x] || a[:y]
    RUBY
  end

  it 'does not register an offense for a four-element fallback chain' do
    expect_no_offenses(<<~RUBY)
      a[:x] || a[:y] || a[:z] || 1
    RUBY
  end

  it 'registers an offense when rhs is not a hash access' do
    expect_offense(<<~RUBY)
      a[:x] || b.foo
      ^^^^^^^^^^^^^^ Sgcop/HashFetchDefault: Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.
    RUBY

    expect_correction(<<~RUBY)
      a.fetch(:x, b.foo)
    RUBY
  end

  it 'registers an offense when rhs is a hash access on a different receiver' do
    expect_offense(<<~RUBY)
      a[:x] || b[:y]
      ^^^^^^^^^^^^^^ Sgcop/HashFetchDefault: Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.
    RUBY

    expect_correction(<<~RUBY)
      a.fetch(:x, b[:y])
    RUBY
  end

  it 'registers an offense for the inner or of a chain whose rhs is not a hash access' do
    expect_offense(<<~RUBY)
      config[:timeout] || DEFAULT_TIMEOUT || 30
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/HashFetchDefault: Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.
    RUBY

    expect_correction(<<~RUBY)
      config.fetch(:timeout, DEFAULT_TIMEOUT) || 30
    RUBY
  end

  it 'registers an offense when the or is on the rhs of an outer or' do
    expect_offense(<<~RUBY)
      foo or a[:x] || bar
             ^^^^^^^^^^^^ Sgcop/HashFetchDefault: Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.
    RUBY

    expect_correction(<<~RUBY)
      foo or a.fetch(:x, bar)
    RUBY
  end

  it 'registers an offense for the inner or when the outer rhs is a same-receiver hash access but the inner rhs is not' do
    expect_offense(<<~RUBY)
      a[:x] || compute_default || a[:z]
      ^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/HashFetchDefault: Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.
    RUBY

    expect_correction(<<~RUBY)
      a.fetch(:x, compute_default) || a[:z]
    RUBY
  end

  it 'registers an offense for the inner or when the inner rhs is a different-receiver hash access' do
    expect_offense(<<~RUBY)
      a[:x] || b[:y] || a[:z]
      ^^^^^^^^^^^^^^ Sgcop/HashFetchDefault: Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.
    RUBY

    expect_correction(<<~RUBY)
      a.fetch(:x, b[:y]) || a[:z]
    RUBY
  end
end
