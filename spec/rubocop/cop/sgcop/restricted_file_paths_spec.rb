require 'spec_helper'

describe RuboCop::Cop::Sgcop::RestrictedFilePaths do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new(
      'Sgcop/RestrictedFilePaths' => {
        'RestrictedPatterns' => {
          'spec/controllers/**/*_spec.rb' => 'コントローラスペックの作成は禁止されています。request specを使用してください。',
        },
      }
    )
  end

  context 'コントローラスペックの場合' do
    it 'spec/controllers/配下のファイルで警告される' do
      expect_offense(<<~RUBY, 'spec/controllers/some_controller_spec.rb')
        describe SomeController do
        ^{} コントローラスペックの作成は禁止されています。request specを使用してください。
        end
      RUBY
    end

    it 'spec/controllers/配下のサブディレクトリでも警告される' do
      expect_offense(<<~RUBY, 'spec/controllers/admin/users_controller_spec.rb')
        describe Admin::UsersController do
        ^{} コントローラスペックの作成は禁止されています。request specを使用してください。
        end
      RUBY
    end

    it 'spec/requests/配下のファイルでは警告されない' do
      expect_no_offenses(<<~RUBY, 'spec/requests/some_controller_spec.rb')
        describe 'SomeController' do
        end
      RUBY
    end
  end

  context 'その他のファイルパターンの場合' do
    let(:config) do
      RuboCop::Config.new(
        'Sgcop/RestrictedFilePaths' => {
          'RestrictedPatterns' => {
            'app/models/**/legacy_*.rb' => 'Legacy モデルの使用は非推奨です。新しいモデルを作成してください。',
            'lib/deprecated/**/*.rb' => 'このディレクトリは非推奨です。lib/current/ を使用してください。',
          },
        }
      )
    end

    it 'legacyモデルで警告される' do
      expect_offense(<<~RUBY, 'app/models/legacy_user.rb')
        class LegacyUser < ApplicationRecord
        ^{} Legacy モデルの使用は非推奨です。新しいモデルを作成してください。
        end
      RUBY
    end

    it 'deprecatedディレクトリで警告される' do
      expect_offense(<<~RUBY, 'lib/deprecated/old_helper.rb')
        module OldHelper
        ^{} このディレクトリは非推奨です。lib/current/ を使用してください。
        end
      RUBY
    end

    it '通常のモデルでは警告されない' do
      expect_no_offenses(<<~RUBY, 'app/models/user.rb')
        class User < ApplicationRecord
        end
      RUBY
    end
  end

  context '設定が空の場合' do
    let(:config) do
      RuboCop::Config.new(
        'Sgcop/RestrictedFilePaths' => {
          'RestrictedPatterns' => {},
        }
      )
    end

    it '警告が発生しない' do
      expect_no_offenses(<<~RUBY, 'spec/controllers/some_controller_spec.rb')
        describe SomeController do
        end
      RUBY
    end
  end
end
