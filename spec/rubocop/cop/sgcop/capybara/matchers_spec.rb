require 'spec_helper'

describe RuboCop::Cop::Sgcop::Capybara::Matchers, :config do
  let(:cop_config) do
    {
      'PreferredMethods' => {
        'have_text' => 'have_content'
      }
    }
  end

  it 'registers an offense for have_text' do
    expect_offense(<<~RUBY)
      it do
        expect(page).to have_text 'test'
                        ^^^^^^^^^ Prefer `have_content` over `have_text`.
      end
    RUBY

    expect_correction(<<~RUBY)
      it do
        expect(page).to have_content 'test'
      end
    RUBY
  end
end
