# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Sgcop::Rspec::SpecStabilityCheck do
  subject(:cop) { RuboCop::Cop::Sgcop::Rspec::SpecStabilityCheck.new }

  context 'with default configuration' do
    it 'registers an offense when assert_enqueued_emails block lacks wait matcher' do
      expect_offense(<<~RUBY)
        assert_enqueued_emails 1 do
        ^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/SpecStabilityCheck: ページの変化を伴う非同期処理後には、適切な待機処理（例: expect(page).to have_content('更新しました。')）を追加してテストを安定させましょう
          within('tbody tr', text: '第2希望') do
            click_button '確定する'
          end
        end
      RUBY
    end

    it 'does not register an offense when assert_enqueued_emails block has wait matcher' do
      expect_no_offenses(<<~RUBY)
        assert_enqueued_emails 1 do
          within('tbody tr', text: '第2希望') do
            click_button '確定する'
            expect(page).to have_content('更新しました。')
          end
        end
      RUBY
    end

    it 'registers an offense for form submission without wait matcher' do
      expect_offense(<<~RUBY)
        assert_enqueued_emails 1 do
        ^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/SpecStabilityCheck: ページの変化を伴う非同期処理後には、適切な待機処理（例: expect(page).to have_content('更新しました。')）を追加してテストを安定させましょう
          fill_in 'Email', with: 'user@example.com'
          click_button '送信'
        end
      RUBY
    end

    it 'does not register an offense for form submission with wait matcher' do
      expect_no_offenses(<<~RUBY)
        assert_enqueued_emails 1 do
          fill_in 'Email', with: 'user@example.com'
          click_button '送信'
          expect(page).to have_content('送信しました')
        end
      RUBY
    end

    it 'registers an offense for cancellation action without wait matcher' do
      expect_offense(<<~RUBY)
        assert_no_emails do
        ^^^^^^^^^^^^^^^^ Sgcop/Rspec/SpecStabilityCheck: ページの変化を伴う非同期処理後には、適切な待機処理（例: expect(page).to have_content('更新しました。')）を追加してテストを安定させましょう
          click_button 'キャンセル'
        end
      RUBY
    end

    it 'works with different wait matchers' do
      expect_no_offenses(<<~RUBY)
        assert_enqueued_emails 1 do
          fill_in 'Name', with: 'John'
          click_button '送信'
          expect(page).to have_css('.success-message')
        end
      RUBY

      expect_no_offenses(<<~RUBY)
        assert_enqueued_emails 1 do
          select '重要', from: 'Priority'
          click_button '保存'
          expect(page).to have_selector('#notification')
        end
      RUBY
    end

    it 'ignores non-watched methods' do
      expect_no_offenses(<<~RUBY)
        perform_enqueued_jobs do
          fill_in 'Message', with: 'Test'
          click_button '送信'
        end
      RUBY
    end
  end

  context 'with custom configuration' do
    subject(:cop) do
      config = RuboCop::Config.new(
        'Sgcop/Rspec/SpecStabilityCheck' => {
          'WatchedMethods' => %w[assert_enqueued_jobs],
          'WaitMatchers' => %w[have_text custom_matcher],
        }
      )
      RuboCop::Cop::Sgcop::Rspec::SpecStabilityCheck.new(config)
    end

    it 'works with custom watched methods for background jobs' do
      expect_offense(<<~RUBY)
        assert_enqueued_jobs 1 do
        ^^^^^^^^^^^^^^^^^^^^^^ ページの変化を伴う非同期処理後には、適切な待機処理（例: expect(page).to have_content('更新しました。')）を追加してテストを安定させましょう
          click_button 'バックグラウンド処理開始'
        end
      RUBY
    end

    it 'works with custom wait matchers for background jobs' do
      expect_no_offenses(<<~RUBY)
        assert_enqueued_jobs 1 do
          click_button 'バックグラウンド処理開始'
          expect(page).to have_text('処理を開始しました')
        end
      RUBY

      expect_no_offenses(<<~RUBY)
        assert_enqueued_jobs 1 do
          check 'Send notification'
          click_button 'Save'
          expect(page).to custom_matcher
        end
      RUBY
    end

    it 'ignores default matchers when custom ones are configured' do
      expect_offense(<<~RUBY)
        assert_enqueued_jobs 1 do
        ^^^^^^^^^^^^^^^^^^^^^^ ページの変化を伴う非同期処理後には、適切な待機処理（例: expect(page).to have_content('更新しました。')）を追加してテストを安定させましょう
          click_button 'Start processing'
          expect(page).to have_content('Processing started')  # have_contentはカスタム設定に含まれていない
        end
      RUBY
    end
  end
end
