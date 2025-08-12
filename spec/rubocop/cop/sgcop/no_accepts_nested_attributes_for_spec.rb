require 'spec_helper'

describe RuboCop::Cop::Sgcop::NoAcceptsNestedAttributesFor do
  subject(:cop) { RuboCop::Cop::Sgcop::NoAcceptsNestedAttributesFor.new }

  context 'accepts_nested_attributes_forが使用されている場合' do
    it '単一のアソシエーションで違反が検出される' do
      expect_offense(<<~RUBY)
        class User < ApplicationRecord
          accepts_nested_attributes_for :posts
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NoAcceptsNestedAttributesFor: Avoid using `accepts_nested_attributes_for`. Consider using Form Objects instead.
        end
      RUBY
    end

    it '複数のアソシエーションで違反が検出される' do
      expect_offense(<<~RUBY)
        class User < ApplicationRecord
          accepts_nested_attributes_for :posts, :comments
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NoAcceptsNestedAttributesFor: Avoid using `accepts_nested_attributes_for`. Consider using Form Objects instead.
        end
      RUBY
    end
  end
end
