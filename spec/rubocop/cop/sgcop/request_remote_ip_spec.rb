require 'spec_helper'

describe RuboCop::Cop::Sgcop::RequestRemoteIp do
  subject(:cop) { RuboCop::Cop::Sgcop::RequestRemoteIp.new }

  it 'request.remote_addrが呼ばれていたら警告' do
    expect_offense(<<~RUBY)
      def log
        logger.info request.remote_addr
                    ^^^^^^^^^^^^^^^^^^^ Sgcop/RequestRemoteIp: Use `request.remote_ip` instead of `request.remote_addr`.
      end
    RUBY
  end

  it 'request.remote_ipが呼ばれていたら警告なし' do
    expect_no_offenses(<<~RUBY)
      def log
        logger.info request.remote_ip
      end
    RUBY
  end
end
