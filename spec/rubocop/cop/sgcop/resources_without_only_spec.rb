require 'spec_helper'

describe RuboCop::Cop::Sgcop::ResourcesWithoutOnly do
  subject(:cop) { RuboCop::Cop::Sgcop::ResourcesWithoutOnly.new }

  context 'resources with only option' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, only: [:index, :show]
        end
      RUBY
    end

    it 'does not register an offense with single action' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, only: :show
        end
      RUBY
    end

    it 'does not register an offense with percent notation' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, only: %i[show edit]
        end
      RUBY
    end
  end

  context 'resources with except option only' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, except: [:destroy]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        end
      RUBY
    end
  end

  context 'resources without any options' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users
          ^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        end
      RUBY
    end

    it 'registers an offense with other options' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, path: 'members'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        end
      RUBY
    end
  end

  context 'resource (singular)' do
    it 'registers an offense without only option' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resource :profile
          ^^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        end
      RUBY
    end

    it 'registers an offense with except option only' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resource :profile, except: [:destroy]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        end
      RUBY
    end

    it 'does not register an offense with only option' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resource :profile, only: [:show, :edit, :update]
        end
      RUBY
    end
  end

  context 'routes in subdirectory' do
    it 'registers an offense in config/routes/*.rb' do
      expect_offense(<<~RUBY, 'config/routes/admin.rb')
        Rails.application.routes.draw do
          resources :users
          ^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        end
      RUBY
    end

    it 'does not register an offense with only option in subdirectory' do
      expect_no_offenses(<<~RUBY, 'config/routes/api.rb')
        Rails.application.routes.draw do
          resources :users, only: [:index]
        end
      RUBY
    end
  end


  context 'nested resources' do
    it 'registers offense for both parent and child resources without only' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users do
          ^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
            resources :posts
            ^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
          end
        end
      RUBY
    end

    it 'registers offense only for resources without only option' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, only: [:index] do
            resources :posts
            ^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
          end
        end
      RUBY
    end
  end

  context 'resources with both only and except options' do
    it 'does not register an offense when only option is present' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, only: [:index], except: [:show]
        end
      RUBY
    end
  end
end