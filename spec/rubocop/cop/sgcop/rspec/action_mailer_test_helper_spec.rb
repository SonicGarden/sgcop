require 'spec_helper'

describe RuboCop::Cop::Sgcop::Rspec::ActionMailerTestHelper do
  subject(:cop) { RuboCop::Cop::Sgcop::Rspec::ActionMailerTestHelper.new }

  context 'in spec files' do
    it 'registers an offense for ActionMailer::Base.deliveries' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        ActionMailer::Base.deliveries
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActionMailerTestHelper: Use ActionMailer::TestHelper methods instead of ActionMailer::Base.deliveries.
      RUBY
    end

    it 'registers an offense for ActionMailer::Base.deliveries.size' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        ActionMailer::Base.deliveries.size
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActionMailerTestHelper: Use `assert_emails(count)` instead of ActionMailer::Base.deliveries.size.
      RUBY
    end

    it 'registers an offense for ActionMailer::Base.deliveries.count' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        ActionMailer::Base.deliveries.count
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActionMailerTestHelper: Use `assert_emails(count)` instead of ActionMailer::Base.deliveries.count.
      RUBY
    end

    it 'registers an offense for ActionMailer::Base.deliveries.empty?' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        ActionMailer::Base.deliveries.empty?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActionMailerTestHelper: Use `assert_no_emails` instead of ActionMailer::Base.deliveries.empty?.
      RUBY
    end

    it 'registers an offense for ActionMailer::Base.deliveries.any?' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        ActionMailer::Base.deliveries.any?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActionMailerTestHelper: Use `assert_emails` to verify emails were sent instead of ActionMailer::Base.deliveries.any?.
      RUBY
    end

    it 'registers an offense for ActionMailer::Base.deliveries.first' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        ActionMailer::Base.deliveries.first
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActionMailerTestHelper: Use `capture_emails { ... }` to access sent emails instead of ActionMailer::Base.deliveries.first.
      RUBY
    end

    it 'registers an offense for ActionMailer::Base.deliveries.last' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        ActionMailer::Base.deliveries.last
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActionMailerTestHelper: Use `capture_emails { ... }` to access sent emails instead of ActionMailer::Base.deliveries.last.
      RUBY
    end

    it 'registers an offense for ActionMailer::Base.deliveries[0]' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        ActionMailer::Base.deliveries[0]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActionMailerTestHelper: Use `capture_emails { ... }` to access sent emails instead of ActionMailer::Base.deliveries.[].
      RUBY
    end

    it 'registers an offense for chained method calls' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        expect(ActionMailer::Base.deliveries.size).to eq(1)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActionMailerTestHelper: Use `assert_emails(count)` instead of ActionMailer::Base.deliveries.size.
      RUBY
    end

    it 'registers an offense for ActionMailer::Base.deliveries.clear' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        ActionMailer::Base.deliveries.clear
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActionMailerTestHelper: Use ActionMailer::TestHelper methods instead of ActionMailer::Base.deliveries.
      RUBY
    end
  end
end
