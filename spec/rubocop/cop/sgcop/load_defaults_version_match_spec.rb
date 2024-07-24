require 'spec_helper'

describe RuboCop::Cop::Sgcop::LoadDefaultsVersionMatch do
  subject(:cop) { described_class.new }

  let(:gemfile_lock_content) { '    rails (6.1.3.4)' }

  before do
    allow(File).to receive(:exist?).and_return(true)
    allow(Dir).to receive(:pwd).and_return('/fakepath')
    allow(File).to receive(:read).with('/fakepath/Gemfile.lock').and_return(gemfile_lock_content)
  end

  it 'registers an offense when load_defaults version does not match Rails version' do
    expect_offense(<<~RUBY)
      config.load_defaults 6.0
      ^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/LoadDefaultsVersionMatch: The load_defaults version (6.0) does not match the Rails version (6.1) specified in the Gemfile.
    RUBY
  end

  it 'does not register an offense when load_defaults version matches Rails version' do
    expect_no_offenses(<<~RUBY)
      config.load_defaults 6.1
    RUBY
  end
end
