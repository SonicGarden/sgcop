require 'spec_helper'

describe RuboCop::Cop::Sgcop::UjsOptions do
  subject(:cop) { described_class.new }

  context 'link_to' do
    it 'methodオプションは警告' do
      expect_offense(<<~RUBY)
        link_to 'title', url, method: :delete
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/UjsOptions: Deprecated: Rails UJS Attributes.
      RUBY
    end

    it 'remoteオプションは警告' do
      expect_offense(<<~RUBY)
        link_to 'title', url, remote: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/UjsOptions: Deprecated: Rails UJS Attributes.
      RUBY
    end
  end

  context 'form_with' do
    it 'remoteオプションは警告' do
      expect_offense(<<~RUBY)
        form_with model: @user, remote: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/UjsOptions: Deprecated: Rails UJS Attributes.
      RUBY
    end

    it 'localオプションは警告' do
      expect_offense(<<~RUBY)
        form_with model: @user, local: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/UjsOptions: Deprecated: Rails UJS Attributes.
      RUBY
    end

    it 'methodオプションは警告なし' do
      expect_no_offenses(<<~RUBY)
        form_with model: @user, method: :patch
      RUBY
    end
  end

  context 'form_for' do
    it 'remoteオプションは警告' do
      expect_offense(<<~RUBY)
        form_for @user, remote: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/UjsOptions: Deprecated: Rails UJS Attributes.
      RUBY
    end

    it 'localオプションは警告' do
      expect_offense(<<~RUBY)
        form_for @user, local: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/UjsOptions: Deprecated: Rails UJS Attributes.
      RUBY
    end

    it 'methodオプションは警告なし' do
      expect_no_offenses(<<~RUBY)
        form_for @user, method: :put
      RUBY
    end
  end

  context 'simple_form_for' do
    it 'remoteオプションは警告' do
      expect_offense(<<~RUBY)
        simple_form_for @user, remote: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/UjsOptions: Deprecated: Rails UJS Attributes.
      RUBY
    end

    it 'localオプションは警告' do
      expect_offense(<<~RUBY)
        simple_form_for @user, local: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/UjsOptions: Deprecated: Rails UJS Attributes.
      RUBY
    end

    it 'methodオプションは警告なし' do
      expect_no_offenses(<<~RUBY)
        simple_form_for @user, method: :patch
      RUBY
    end
  end

  context 'bootstrap_form_with' do
    it 'remoteオプションは警告' do
      expect_offense(<<~RUBY)
        bootstrap_form_with model: @user, remote: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/UjsOptions: Deprecated: Rails UJS Attributes.
      RUBY
    end

    it 'localオプションは警告' do
      expect_offense(<<~RUBY)
        bootstrap_form_with model: @user, local: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/UjsOptions: Deprecated: Rails UJS Attributes.
      RUBY
    end

    it 'methodオプションは警告なし' do
      expect_no_offenses(<<~RUBY)
        bootstrap_form_with model: @user, method: :delete
      RUBY
    end
  end

  context 'other methods' do
    it 'button_toに対するmethodオプションは警告無し' do
      expect_no_offenses(<<~RUBY)
        button_to 'Delete', url, method: :delete
      RUBY
    end

    it 'button_toに対するremoteオプションは警告無し' do
      expect_no_offenses(<<~RUBY)
        button_to 'Submit', url, remote: true
      RUBY
    end
  end
end
