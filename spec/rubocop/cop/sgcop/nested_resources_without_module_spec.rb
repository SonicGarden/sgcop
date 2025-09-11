require 'spec_helper'

describe RuboCop::Cop::Sgcop::NestedResourcesWithoutModule do
  subject(:cop) { RuboCop::Cop::Sgcop::NestedResourcesWithoutModule.new }

  context 'nested resources with module option' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            resources :comments, only: %i[create], module: :posts
          end
        end
      RUBY
    end
  end

  context 'nested resources with namespace option' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            resources :comments, only: %i[create], namespace: :posts
          end
        end
      RUBY
    end
  end

  context 'nested resources with scope option' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            resources :comments, only: %i[create], scope: :posts
          end
        end
      RUBY
    end
  end

  context 'nested resources without module option' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            resources :comments, only: %i[create]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NestedResourcesWithoutModule: Use `module:` option in nested resource/resources routing.
          end
        end
      RUBY
    end

    it 'registers an offense with other options' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            resources :comments, only: %i[create], path: 'remarks'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NestedResourcesWithoutModule: Use `module:` option in nested resource/resources routing.
          end
        end
      RUBY
    end
  end

  context 'nested resource (singular) without module option' do
    it 'registers an offense' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            resource :comment, only: %i[create]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NestedResourcesWithoutModule: Use `module:` option in nested resource/resources routing.
          end
        end
      RUBY
    end
  end

  context 'deeply nested resources' do
    it 'registers offense for nested resources without module' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            resources :comments, only: %i[index create], module: :posts do
              resources :reactions, only: %i[create]
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NestedResourcesWithoutModule: Use `module:` option in nested resource/resources routing.
            end
          end
        end
      RUBY
    end

    it 'does not register offense when all have module' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            resources :comments, only: %i[index create], module: :posts do
              resources :reactions, only: %i[create], module: :comments
            end
          end
        end
      RUBY
    end
  end

  context 'top-level resources' do
    it 'does not register an offense for non-nested resources' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy]
          resources :comments, only: %i[index create]
        end
      RUBY
    end
  end

  context 'multiple nested resources in same block' do
    it 'registers offense for each without module' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            resources :comments, only: %i[create]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NestedResourcesWithoutModule: Use `module:` option in nested resource/resources routing.
            resources :likes, only: %i[create destroy]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NestedResourcesWithoutModule: Use `module:` option in nested resource/resources routing.
          end
        end
      RUBY
    end

    it 'registers offense only for those without module' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            resources :comments, only: %i[create], module: :posts
            resources :likes, only: %i[create destroy]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NestedResourcesWithoutModule: Use `module:` option in nested resource/resources routing.
          end
        end
      RUBY
    end
  end

  context 'resources with member block' do
    it 'does not register offense for member actions' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            member do
              get :preview
              patch :publish
            end
          end
        end
      RUBY
    end

    it 'does not register offense for nested resources with member block' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts do
            resources :comments, only: %i[create destroy], module: :posts do
              member do
                patch :approve
                patch :reject
              end
            end
          end
        end
      RUBY
    end
  end

  context 'resources with collection block' do
    it 'does not register offense for collection actions' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts, only: %i[index show new edit create update destroy] do
            collection do
              get :search
              post :bulk_update
            end
          end
        end
      RUBY
    end
  end

  context 'nested resources with member block without module' do
    it 'registers offense for resources without module even with member block' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :posts do
            resources :comments, only: %i[create destroy] do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/NestedResourcesWithoutModule: Use `module:` option in nested resource/resources routing.
              member do
                patch :approve
                patch :reject
              end
            end
          end
        end
      RUBY
    end
  end
end
