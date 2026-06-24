require 'spec_helper'

describe RuboCop::Cop::Sgcop::ActiveStorageServiceConfiguration do
  subject(:cop) { described_class.new }

  let(:storage_yml) { "test:\n  service: Disk\nlocal:\n  service: Disk\namazon:\n  service: S3\n" }
  let(:storage_yml_exists) { true }

  before do
    allow(Dir).to receive(:pwd).and_return('/fakepath')
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/fakepath/config/storage.yml').and_return(storage_yml_exists)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with('/fakepath/config/storage.yml').and_return(storage_yml)
  end

  context 'when storage.yml has a cloud service' do
    it 'registers an offense for service = :local' do
      expect_offense(<<~RUBY, 'config/environments/production.rb')
        Rails.application.configure do
          config.active_storage.service = :local
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ActiveStorageServiceConfiguration: Do not use :local for config.active_storage.service in production.
        end
      RUBY
    end

    it 'registers an offense when the service setting is missing' do
      expect_offense(<<~RUBY, 'config/environments/production.rb')
        Rails.application.configure do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ActiveStorageServiceConfiguration: Set config.active_storage.service for production. Active Storage uses local disk by default.
          config.enable_reloading = false
        end
      RUBY
    end

    it 'does not register an offense for a cloud service' do
      expect_no_offenses(<<~RUBY, 'config/environments/production.rb')
        Rails.application.configure do
          config.active_storage.service = :amazon
        end
      RUBY
    end
  end

  context 'when storage.yml only has Disk services' do
    let(:storage_yml) { "test:\n  service: Disk\nlocal:\n  service: Disk\n" }

    it 'does not register an offense even when the service setting is missing' do
      expect_no_offenses(<<~RUBY, 'config/environments/production.rb')
        Rails.application.configure do
          config.enable_reloading = false
        end
      RUBY
    end
  end

  context 'when storage.yml does not exist' do
    let(:storage_yml_exists) { false }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'config/environments/production.rb')
        Rails.application.configure do
          config.enable_reloading = false
        end
      RUBY
    end
  end

  context 'when the file is not production.rb' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'config/environments/development.rb')
        Rails.application.configure do
          config.enable_reloading = true
        end
      RUBY
    end
  end
end
