require 'spec_helper'

describe RuboCop::Cop::Sgcop::ErrorMessageFormat do
  subject(:cop) { RuboCop::Cop::Sgcop::ErrorMessageFormat.new }

  it 'registers an offense for validates with hardcoded message string' do
    expect_offense(<<~RUBY)
      validates :terms_of_service, acceptance: { message: "must be agreed to" }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ErrorMessageFormat: Error message should be a symbol.
    RUBY
  end

  it 'registers an offense for validates with Japanese hardcoded message' do
    expect_offense(<<~RUBY)
      validates :name, presence: { message: "は必須です" }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ErrorMessageFormat: Error message should be a symbol.
    RUBY
  end

  it 'registers an offense for errors.add with hardcoded string' do
    expect_offense(<<~RUBY)
      errors.add(:name, 'は不正な文字列です。')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ErrorMessageFormat: Error message should be a symbol.
    RUBY
  end

  it 'registers an offense for errors.add with English message' do
    expect_offense(<<~RUBY)
      errors.add(:email, "is invalid")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ErrorMessageFormat: Error message should be a symbol.
    RUBY
  end

  it 'registers an offense for errors.add with interpolated string' do
    expect_offense(<<~'RUBY')
      errors.add(:base, "#{field} is required")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ErrorMessageFormat: Error message should be a symbol.
    RUBY
  end

  it 'does not register an offense for validates without message option' do
    expect_no_offenses(<<~RUBY)
      validates :name, presence: true
    RUBY
  end

  it 'does not register an offense for validates with symbol message' do
    expect_no_offenses(<<~RUBY)
      validates :name, presence: { message: :blank }
    RUBY
  end

  it 'does not register an offense for errors.add with symbol' do
    expect_no_offenses(<<~RUBY)
      errors.add(:name, :invalid)
    RUBY
  end

  it 'does not register an offense for errors.add with I18n.t' do
    expect_no_offenses(<<~RUBY)
      errors.add(:name, I18n.t('errors.messages.invalid'))
    RUBY
  end

  it 'does not register an offense for validates with I18n.t message' do
    expect_no_offenses(<<~RUBY)
      validates :name, presence: { message: I18n.t('errors.messages.blank') }
    RUBY
  end

  it 'registers an offense for validates with proc message' do
    expect_offense(<<~RUBY)
      validates :name, presence: { message: -> { I18n.t('errors.messages.blank') } }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ErrorMessageFormat: Error message should be a symbol.
    RUBY
  end

  it 'does not register an offense for errors.add with local variable' do
    expect_no_offenses(<<~RUBY)
      message = calculate_message
      errors.add(:name, message)
    RUBY
  end

  it 'does not register an offense for errors.add with instance variable' do
    expect_no_offenses(<<~RUBY)
      errors.add(:name, @message)
    RUBY
  end

  it 'does not register an offense for errors.add with class variable' do
    expect_no_offenses(<<~RUBY)
      errors.add(:name, @@message)
    RUBY
  end

  it 'does not register an offense for errors.add with global variable' do
    expect_no_offenses(<<~RUBY)
      errors.add(:name, $message)
    RUBY
  end

  it 'does not register an offense for errors.add with method call' do
    expect_no_offenses(<<~RUBY)
      errors.add(:name, generate_message)
    RUBY
  end

  it 'does not register an offense for errors.add with method call with arguments' do
    expect_no_offenses(<<~RUBY)
      errors.add(:name, format_message(:invalid))
    RUBY
  end
end
