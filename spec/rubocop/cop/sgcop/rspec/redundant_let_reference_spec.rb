require 'spec_helper'

describe RuboCop::Cop::Sgcop::Rspec::RedundantLetReference do
  subject(:cop) { RuboCop::Cop::Sgcop::Rspec::RedundantLetReference.new }

  context 'when let is referenced only in before block' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        let(:user) { create(:user) }

        before do
          user
          ^^^^ Sgcop/Rspec/RedundantLetReference: Use `let!` instead of referencing `let` in `before` block, or move the setup directly into `before`.
        end
      RUBY
    end
  end

  context 'when let is referenced only in it block' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        let(:user) { create(:user) }

        it do
          user
          ^^^^ Sgcop/Rspec/RedundantLetReference: Use `let!` for eager evaluation or move the setup directly into the test block instead of just referencing `let`.
        end
      RUBY
    end
  end

  context 'when let is referenced with other statements in before block' do
    it 'registers an offense for the let reference' do
      expect_offense(<<~RUBY)
        let(:user) { create(:user) }

        before do
          user
          ^^^^ Sgcop/Rspec/RedundantLetReference: Use `let!` instead of referencing `let` in `before` block, or move the setup directly into `before`.
          do_something
        end
      RUBY
    end
  end

  context 'when let is referenced with other statements in it block' do
    it 'registers an offense for the let reference' do
      expect_offense(<<~RUBY)
        let(:user) { create(:user) }

        it do
          user
          ^^^^ Sgcop/Rspec/RedundantLetReference: Use `let!` for eager evaluation or move the setup directly into the test block instead of just referencing `let`.
          visit home_path
        end
      RUBY
    end
  end

  context 'when let is used meaningfully in before block' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        let(:user) { create(:user) }

        before do
          user.update(name: 'test')
        end
      RUBY
    end
  end

  context 'when let is used meaningfully in it block' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        let(:user) { create(:user) }

        it do
          expect(user.name).to eq('test')
        end
      RUBY
    end
  end

  context 'when let is assigned to a variable' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        let(:user) { create(:user) }

        it do
          current_user = user
          expect(current_user.name).to eq('test')
        end
      RUBY
    end
  end

  context 'when let! is used instead of let' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        let!(:user) { create(:user) }

        before do
          # no need to reference user
        end
      RUBY
    end
  end

  context 'when variable is not defined by let' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def user
          @user ||= create(:user)
        end

        before do
          user
        end
      RUBY
    end
  end

  context 'when let reference has arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        let(:user) { create(:user) }

        it do
          user(some_arg)
        end
      RUBY
    end
  end

  context 'when let reference has a receiver' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        let(:user) { create(:user) }

        it do
          something.user
        end
      RUBY
    end
  end
end
