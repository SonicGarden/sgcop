require 'spec_helper'

describe RuboCop::Cop::Sgcop::Rspec::ActiveJobTestHelper do
  subject(:cop) { RuboCop::Cop::Sgcop::Rspec::ActiveJobTestHelper.new }

  context 'in spec files' do
    it 'registers an offense for have_enqueued_job matcher' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        expect { User.create }.to have_enqueued_job(UserMailerJob)
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActiveJobTestHelper: Use `assert_enqueued_jobs(count)` or `assert_enqueued_with` instead of `have_enqueued_job`.
      RUBY
    end

    it 'registers an offense for have_enqueued_job with arguments' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        expect { User.create }.to have_enqueued_job(UserMailerJob).with(user_id: 1)
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActiveJobTestHelper: Use `assert_enqueued_jobs(count)` or `assert_enqueued_with` instead of `have_enqueued_job`.
      RUBY
    end

    it 'registers an offense for have_been_enqueued matcher' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        expect(UserMailerJob).to have_been_enqueued
                                 ^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActiveJobTestHelper: Use `assert_enqueued_with` instead of `have_been_enqueued`.
      RUBY
    end

    it 'registers an offense for enqueue_job matcher' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        expect { User.create }.to enqueue_job(UserMailerJob)
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActiveJobTestHelper: Use `assert_enqueued_jobs` with a block instead of `enqueue_job`.
      RUBY
    end

    it 'registers an offense for have_performed_job matcher' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        expect { User.create }.to have_performed_job(UserMailerJob)
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActiveJobTestHelper: Use `assert_performed_jobs(count)` or `assert_performed_with` instead of `have_performed_job`.
      RUBY
    end

    it 'registers an offense for have_been_performed matcher' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        expect(UserMailerJob).to have_been_performed
                                 ^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActiveJobTestHelper: Use `assert_performed_with` instead of `have_been_performed`.
      RUBY
    end

    it 'registers an offense for perform_job matcher' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        expect { User.create }.to perform_job(UserMailerJob)
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActiveJobTestHelper: Use `assert_performed_jobs` with a block instead of `perform_job`.
      RUBY
    end

    it 'registers an offense with not_to' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        expect { User.create }.not_to have_enqueued_job(UserMailerJob)
                                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActiveJobTestHelper: Use `assert_enqueued_jobs(count)` or `assert_enqueued_with` instead of `have_enqueued_job`.
      RUBY
    end

    it 'registers an offense with to_not' do
      expect_offense(<<~RUBY, 'spec/models/user_spec.rb')
        expect { User.create }.to_not enqueue_job(UserMailerJob)
                                      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/ActiveJobTestHelper: Use `assert_enqueued_jobs` with a block instead of `enqueue_job`.
      RUBY
    end

    it 'does not register an offense for other matchers' do
      expect_no_offenses(<<~RUBY, 'spec/models/user_spec.rb')
        expect(User.count).to eq(1)
      RUBY
    end

    it 'does not register an offense for assert_enqueued_jobs' do
      expect_no_offenses(<<~RUBY, 'spec/models/user_spec.rb')
        assert_enqueued_jobs(1) { User.create }
      RUBY
    end
  end
end
