require 'spec_helper'

describe RuboCop::Cop::Sgcop::MethodArgumentNameDuplication do
  subject(:cop) { described_class.new }

  it 'registers an offense when a positional argument has the same name as the method' do
    expect_offense(<<~RUBY)
      def request(request)
                  ^^^^^^^ Sgcop/MethodArgumentNameDuplication: Method name `request` and argument name `request` are identical, which is confusing. Rename one of them.
      end
    RUBY
  end

  it 'registers an offense for a singleton method' do
    expect_offense(<<~RUBY)
      def self.request(request)
                       ^^^^^^^ Sgcop/MethodArgumentNameDuplication: Method name `request` and argument name `request` are identical, which is confusing. Rename one of them.
      end
    RUBY
  end

  it 'registers an offense for a keyword argument' do
    expect_offense(<<~RUBY)
      def request(request:)
                  ^^^^^^^^ Sgcop/MethodArgumentNameDuplication: Method name `request` and argument name `request` are identical, which is confusing. Rename one of them.
      end
    RUBY
  end

  it 'registers an offense for an optional argument' do
    expect_offense(<<~RUBY)
      def request(request = nil)
                  ^^^^^^^^^^^^^ Sgcop/MethodArgumentNameDuplication: Method name `request` and argument name `request` are identical, which is confusing. Rename one of them.
      end
    RUBY
  end

  it 'registers an offense for a splat argument' do
    expect_offense(<<~RUBY)
      def request(*request)
                  ^^^^^^^^ Sgcop/MethodArgumentNameDuplication: Method name `request` and argument name `request` are identical, which is confusing. Rename one of them.
      end
    RUBY
  end

  it 'registers an offense when one of several arguments matches the method name' do
    expect_offense(<<~RUBY)
      def request(foo, request)
                       ^^^^^^^ Sgcop/MethodArgumentNameDuplication: Method name `request` and argument name `request` are identical, which is confusing. Rename one of them.
      end
    RUBY
  end

  it 'does not register an offense when the argument merely contains the method name' do
    expect_no_offenses(<<~RUBY)
      def request(http_request)
      end
    RUBY
  end

  it 'does not register an offense when the argument has a different name' do
    expect_no_offenses(<<~RUBY)
      def request(body)
      end
    RUBY
  end

  it 'does not register an offense when there are no arguments' do
    expect_no_offenses(<<~RUBY)
      def request
      end
    RUBY
  end

  it 'does not register an offense for an anonymous splat argument' do
    expect_no_offenses(<<~RUBY)
      def request(*)
      end
    RUBY
  end
end
