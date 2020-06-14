require 'spec_helper'

describe RuboCop::Cop::Sgcop::Capybara::Sleep do
  subject(:cop) { RuboCop::Cop::Sgcop::Capybara::Sleep.new }

  it 'registers an offense for an sleep call with no receiver' do
    expect_offense(<<~RUBY)
      it do
        click_on 'button'
        sleep 10
        ^^^^^ Do not use `sleep` in spec.
      end
    RUBY
  end

  it 'does register an offense for explicit Kernel.sleep calls' do
    expect_offense(<<~RUBY)
      it do
        click_on 'button'
        Kernel.sleep 10
               ^^^^^ Do not use `sleep` in spec.
      end
    RUBY
  end

  it 'does not register an offense for an explicit sleep call on an object' do
    expect_no_offenses('Object.new.sleep')
  end
end
