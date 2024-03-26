require 'spec_helper'

describe RuboCop::Cop::Sgcop::OnLoadArguments do
  subject(:cop) { RuboCop::Cop::Sgcop::OnLoadArguments.new }

  it '許可されていない引数の場合は警告される' do
    expect_offense(<<~RUBY)
      ActiveSupport.on_load(:aciton_mailer) do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/OnLoadArguments: Do not use unpermitted name as arguments for `ActiveSupport.on_load`
      end
    RUBY
  end

  it '許可された引数の場合は警告されない' do
    expect_no_offenses(<<~RUBY)
      ActiveSupport.on_load(:active_record) do
      end
    RUBY
  end
end
