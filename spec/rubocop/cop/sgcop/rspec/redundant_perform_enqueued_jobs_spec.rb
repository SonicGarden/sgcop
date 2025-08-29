require 'spec_helper'

describe RuboCop::Cop::Sgcop::Rspec::RedundantPerformEnqueuedJobs do
  subject(:cop) { RuboCop::Cop::Sgcop::Rspec::RedundantPerformEnqueuedJobs.new }

  context 'when perform_enqueued_jobs wraps capture_emails' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'spec/system/user_spec.rb')
        perform_enqueued_jobs do
          emails = capture_emails do
                   ^^^^^^^^^^^^^^ Sgcop/Rspec/RedundantPerformEnqueuedJobs: `capture_emails` internally uses `perform_enqueued_jobs`, so the outer `perform_enqueued_jobs` is redundant.
            click_button '新規登録'
          end
        end
      RUBY
    end
  end

  context 'when perform_enqueued_jobs wraps deliver_enqueued_emails' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'spec/system/user_spec.rb')
        perform_enqueued_jobs do
          deliver_enqueued_emails do
          ^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/RedundantPerformEnqueuedJobs: `deliver_enqueued_emails` internally uses `perform_enqueued_jobs`, so the outer `perform_enqueued_jobs` is redundant.
            UserMailer.welcome.deliver_later
          end
        end
      RUBY
    end
  end

  context 'when perform_enqueued_jobs wraps assert_emails with block' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'spec/system/user_spec.rb')
        perform_enqueued_jobs do
          assert_emails 1 do
          ^^^^^^^^^^^^^^^ Sgcop/Rspec/RedundantPerformEnqueuedJobs: `assert_emails` internally uses `perform_enqueued_jobs`, so the outer `perform_enqueued_jobs` is redundant.
            click_button '新規登録'
          end
        end
      RUBY
    end
  end

  context 'when perform_enqueued_jobs wraps assert_no_emails with block' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'spec/system/user_spec.rb')
        perform_enqueued_jobs do
          assert_no_emails do
          ^^^^^^^^^^^^^^^^ Sgcop/Rspec/RedundantPerformEnqueuedJobs: `assert_no_emails` internally uses `perform_enqueued_jobs`, so the outer `perform_enqueued_jobs` is redundant.
            click_button 'キャンセル'
          end
        end
      RUBY
    end
  end

  context 'when capture_emails is used without perform_enqueued_jobs' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'spec/system/user_spec.rb')
        emails = capture_emails do
          click_button '新規登録'
        end
      RUBY
    end
  end

  context 'when assert_emails without block is used in perform_enqueued_jobs' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'spec/system/user_spec.rb')
        perform_enqueued_jobs do
          UserMailer.welcome.deliver_later
          assert_emails 1
        end
      RUBY
    end
  end

  context 'when assert_no_emails without block is used in perform_enqueued_jobs' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'spec/system/user_spec.rb')
        perform_enqueued_jobs do
          # Some action that shouldn't send emails
          assert_no_emails
        end
      RUBY
    end
  end

  context 'when nested perform_enqueued_jobs with capture_emails' do
    it 'registers an offense for nested capture_emails' do
      expect_offense(<<~RUBY, 'spec/system/user_spec.rb')
        perform_enqueued_jobs do
          some_action
          emails = capture_emails do
                   ^^^^^^^^^^^^^^ Sgcop/Rspec/RedundantPerformEnqueuedJobs: `capture_emails` internally uses `perform_enqueued_jobs`, so the outer `perform_enqueued_jobs` is redundant.
            click_button '送信'
          end
          expect(emails.size).to eq(1)
        end
      RUBY
    end
  end
end
