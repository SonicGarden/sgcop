require 'spec_helper'

describe RuboCop::Cop::Sgcop::ActiveJobQueueAdapter, :config do
  subject(:cop) { described_class.new }

  it 'registers an offense when setting config.active_job.queue_adapter in an initializer' do
    expect_offense(<<~RUBY, 'config/initializers/activejob.rb')
      Rails.application.configure do |config|
        config.active_job.queue_adapter = :sidekiq
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ActiveJobQueueAdapter: Do not set config.active_job.queue_adapter in config/initializers.
      end
    RUBY
  end

  it 'does not register an offense when setting config.active_job.queue_adapter in an config/application.rb' do
    expect_no_offenses(<<~RUBY, 'config/application.rb')
      Rails.application.configure do |config|
        config.active_job.queue_adapter = :sidekiq
      end
    RUBY
  end

  it 'does not register an offense when setting config.active_job.queue_adapter outside of an initializer' do
    expect_no_offenses(<<~RUBY)
      class MyJob < ActiveJob::Base
        queue_adapter :sidekiq
      end
    RUBY
  end

  it 'does not register an offense when setting a different config option in an initializer' do
    expect_no_offenses(<<~RUBY)
      config.active_job.queue_name_prefix = 'my_app'
    RUBY
  end
end
