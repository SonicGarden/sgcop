require 'spec_helper'

describe RuboCop::Cop::Sgcop::UjsOptions do
  subject(:cop) { described_class.new }

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

  it 'button_toに対するmethodオプションは警告無し' do
    expect_no_offenses(<<~RUBY)
      button_to 'Delete', url, method: :delete
    RUBY
  end
end
