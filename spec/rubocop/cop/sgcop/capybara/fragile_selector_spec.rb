require 'spec_helper'

describe RuboCop::Cop::Sgcop::Capybara::FragileSelector, :config do
  it 'registers an offense for CSS class selector with find' do
    expect_offense(<<~RUBY)
      find('.btn-primary').click
           ^^^^^^^^^^^^^^ Avoid using CSS class selectors as they are fragile and break when styles change. Use data attributes or accessible attributes instead.
    RUBY
  end

  it 'registers an offense for ID selector with find' do
    expect_offense(<<~RUBY)
      find('#user_email').set('x')
           ^^^^^^^^^^^^^ Avoid using ID selectors as they are fragile and break when markup changes. Use data attributes or accessible attributes instead.
    RUBY
  end

  it 'registers an offense for partial href matching' do
    expect_offense(<<~RUBY)
      find('a[href*="edit"]').click
           ^^^^^^^^^^^^^^^^^ Avoid using partial href matching as it is fragile. Use data attributes or accessible attributes instead.
    RUBY
  end

  it 'registers an offense for CSS class selector in within block' do
    expect_offense(<<~RUBY)
      within 'div.tw\\:bg-base-200' do
             ^^^^^^^^^^^^^^^^^^^^^ Avoid using CSS class selectors in within blocks. Use data attributes or accessible attributes instead.
        click_on 'Submit'
      end
    RUBY
  end

  it 'registers an offense for element with class selector' do
    expect_offense(<<~RUBY)
      find('div.container').click
           ^^^^^^^^^^^^^^^ Avoid using CSS class selectors as they are fragile and break when styles change. Use data attributes or accessible attributes instead.
    RUBY
  end

  it 'registers an offense for class selector with all' do
    expect_offense(<<~RUBY)
      all('.item').each { |item| item.click }
          ^^^^^^^ Avoid using CSS class selectors as they are fragile and break when styles change. Use data attributes or accessible attributes instead.
    RUBY
  end

  it 'registers an offense for ID selector with first' do
    expect_offense(<<~RUBY)
      first('#header').click
            ^^^^^^^^^ Avoid using ID selectors as they are fragile and break when markup changes. Use data attributes or accessible attributes instead.
    RUBY
  end

  it 'does not register an offense for data attribute selector' do
    expect_no_offenses(<<~RUBY)
      find('[data-test="submit-button"]').click
    RUBY
  end

  it 'does not register an offense for role attribute selector' do
    expect_no_offenses(<<~RUBY)
      find('[role="button"]').click
    RUBY
  end

  it 'does not register an offense for aria-label selector' do
    expect_no_offenses(<<~RUBY)
      find('[aria-label="Close"]').click
    RUBY
  end

  it 'does not register an offense for exact href matching' do
    expect_no_offenses(<<~RUBY)
      find('a[href="/users/edit"]').click
    RUBY
  end

  it 'does not register an offense for text content selector' do
    expect_no_offenses(<<~RUBY)
      click_on 'Submit'
    RUBY
  end

  it 'registers an offense for xpath selector' do
    expect_offense(<<~RUBY)
      find(:xpath, '//button[@type="submit"]').click
           ^^^^^^ Avoid using XPath selectors as they are fragile and break when markup changes. Use data attributes or accessible attributes instead.
    RUBY
  end

  it 'registers an offense for xpath selector in within block' do
    expect_offense(<<~RUBY)
      within :xpath, '//div[@class="container"]' do
             ^^^^^^ Avoid using XPath selectors as they are fragile and break when markup changes. Use data attributes or accessible attributes instead.
        click_on 'Submit'
      end
    RUBY
  end

  it 'does not register an offense for non-string arguments' do
    expect_no_offenses(<<~RUBY)
      find(some_variable).click
    RUBY
  end
end
