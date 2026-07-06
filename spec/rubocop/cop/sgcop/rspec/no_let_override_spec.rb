require 'spec_helper'

describe RuboCop::Cop::Sgcop::Rspec::NoLetOverride do
  subject(:cop) { RuboCop::Cop::Sgcop::Rspec::NoLetOverride.new }

  context 'when a child context overrides a parent let' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        describe User do
          let(:user) { create(:user) }

          context 'when admin' do
            let(:user) { create(:admin) }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/NoLetOverride: `user` is already defined in a parent context. Define it independently instead of overriding.
          end
        end
      RUBY
    end
  end

  context 'when a child context overrides a parent let with let!' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        describe User do
          let(:user) { create(:user) }

          context 'when admin' do
            let!(:user) { create(:admin) }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/NoLetOverride: `user` is already defined in a parent context. Define it independently instead of overriding.
          end
        end
      RUBY
    end
  end

  context 'when a child context overrides a parent named subject with let' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        describe User do
          subject(:user) { create(:user) }

          context 'when admin' do
            let(:user) { create(:admin) }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/NoLetOverride: `user` is already defined in a parent context. Define it independently instead of overriding.
          end
        end
      RUBY
    end
  end

  context 'when a grandchild context overrides a parent let' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        describe User do
          let(:user) { create(:user) }

          context 'level 1' do
            context 'level 2' do
              let(:user) { create(:admin) }
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/Rspec/NoLetOverride: `user` is already defined in a parent context. Define it independently instead of overriding.
            end
          end
        end
      RUBY
    end
  end

  context 'when parent and child use different names' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        describe User do
          let(:user) { create(:user) }

          context 'when admin' do
            let(:admin) { create(:admin) }
          end
        end
      RUBY
    end
  end

  context 'when duplicated within the same example group' do
    it 'does not register an offense (handled by RSpec/OverwritingSetup)' do
      expect_no_offenses(<<~RUBY)
        describe User do
          let(:user) { create(:user) }
          let(:user) { create(:admin) }
        end
      RUBY
    end
  end

  context 'when an anonymous subject is redefined in a child context' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        describe User do
          subject { create(:user) }

          context 'when admin' do
            subject { create(:admin) }
          end
        end
      RUBY
    end
  end

  context 'when let is defined only at the top level of a context' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        describe User do
          let(:user) { create(:user) }

          context 'when admin' do
            it { is_expected.to be_valid }
          end
        end
      RUBY
    end
  end
end
