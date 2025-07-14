require 'spec_helper'

describe RuboCop::Cop::Sgcop::ResourceActionOrder do
  subject(:cop) { RuboCop::Cop::Sgcop::ResourceActionOrder.new }

  context 'resources with only option' do
    it 'correct order' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, only: [:index, :show, :create]
        end
      RUBY
    end

    it 'incorrect order' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, only: [:create, :index, :show]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourceActionOrder: Actions should be ordered in the same sequence as Rails/ActionOrder: index, show, create
        end
      RUBY

      expect_correction(<<~RUBY)
        Rails.application.routes.draw do
          resources :users, only: [:index, :show, :create]
        end
      RUBY
    end

    it 'single action' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, only: :show
        end
      RUBY
    end

    it 'percent notation incorrect order' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, only: %i[edit show]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourceActionOrder: Actions should be ordered in the same sequence as Rails/ActionOrder: show, edit
        end
      RUBY

      expect_correction(<<~RUBY)
        Rails.application.routes.draw do
          resources :users, only: %i[show edit]
        end
      RUBY
    end

    it 'all actions in wrong order' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, only: [:destroy, :update, :create, :edit, :new, :show, :index]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourceActionOrder: Actions should be ordered in the same sequence as Rails/ActionOrder: index, show, new, edit, create, update, destroy
        end
      RUBY

      expect_correction(<<~RUBY)
        Rails.application.routes.draw do
          resources :users, only: [:index, :show, :new, :edit, :create, :update, :destroy]
        end
      RUBY
    end
  end

  context 'resource with only option' do
    it 'correct order' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resource :profile, only: [:show, :edit, :update]
        end
      RUBY
    end

    it 'incorrect order' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resource :profile, only: [:edit, :show, :update]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourceActionOrder: Actions should be ordered in the same sequence as Rails/ActionOrder: show, edit, update
        end
      RUBY

      expect_correction(<<~RUBY)
        Rails.application.routes.draw do
          resource :profile, only: [:show, :edit, :update]
        end
      RUBY
    end
  end

  context 'resources with except option' do
    it 'correct order (implicit)' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, except: [:destroy]
        end
      RUBY
    end

    it 'incorrect order in except' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, except: [:show, :index]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourceActionOrder: Actions should be ordered in the same sequence as Rails/ActionOrder: index, show
        end
      RUBY

      expect_correction(<<~RUBY)
        Rails.application.routes.draw do
          resources :users, except: [:index, :show]
        end
      RUBY
    end
  end

  context 'not routes.rb file' do
    it 'ignores non-routes files' do
      expect_no_offenses(<<~RUBY, 'app/controllers/users_controller.rb')
        class UsersController < ApplicationController
          resources :users, only: [:create, :index, :show]
        end
      RUBY
    end
  end

  context 'resources without action options' do
    it 'ignores resources without only/except' do
      expect_no_offenses(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users
        end
      RUBY
    end
  end

  context 'complex routes structure' do
    it 'handles nested resources' do
      expect_offense(<<~RUBY, 'config/routes.rb')
        Rails.application.routes.draw do
          resources :users, only: [:create, :index] do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourceActionOrder: Actions should be ordered in the same sequence as Rails/ActionOrder: index, create
            resources :posts, only: [:show, :index]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourceActionOrder: Actions should be ordered in the same sequence as Rails/ActionOrder: index, show
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        Rails.application.routes.draw do
          resources :users, only: [:index, :create] do
            resources :posts, only: [:index, :show]
          end
        end
      RUBY
    end
  end
end
