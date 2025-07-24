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

  context 'autocorrect' do
    context 'resources without options' do
      it 'adds only option with all default actions' do
        expect_offense(<<~RUBY, 'config/routes.rb')
          resources :users
          ^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        RUBY

        expect_correction(<<~RUBY)
          resources :users, only: [:index, :show, :new, :create, :edit, :update, :destroy]
        RUBY
      end
    end

    context 'resources with other options' do
      it 'adds only option to existing options' do
        expect_offense(<<~RUBY, 'config/routes.rb')
          resources :users, path: 'members'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        RUBY

        expect_correction(<<~RUBY)
          resources :users, path: 'members', only: [:index, :show, :new, :create, :edit, :update, :destroy]
        RUBY
      end
    end

    context 'resource (singular)' do
      it 'adds only option with default actions (no index)' do
        expect_offense(<<~RUBY, 'config/routes.rb')
          resource :profile
          ^^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        RUBY

        expect_correction(<<~RUBY)
          resource :profile, only: [:show, :new, :create, :edit, :update, :destroy]
        RUBY
      end
    end

    context 'with except option' do
      it 'converts except to only with remaining actions' do
        expect_offense(<<~RUBY, 'config/routes.rb')
          resources :users, except: [:destroy]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        RUBY

        expect_correction(<<~RUBY)
          resources :users, only: [:index, :show, :new, :create, :edit, :update]
        RUBY
      end

      it 'converts except with multiple actions' do
        expect_offense(<<~RUBY, 'config/routes.rb')
          resources :users, except: [:edit, :update, :destroy]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        RUBY

        expect_correction(<<~RUBY)
          resources :users, only: [:index, :show, :new, :create]
        RUBY
      end

      it 'converts except with single action (no array)' do
        expect_offense(<<~RUBY, 'config/routes.rb')
          resources :users, except: :destroy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        RUBY

        expect_correction(<<~RUBY)
          resources :users, only: [:index, :show, :new, :create, :edit, :update]
        RUBY
      end

      it 'converts except with other options present' do
        expect_offense(<<~RUBY, 'config/routes.rb')
          resources :users, path: 'members', except: [:destroy]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        RUBY

        expect_correction(<<~RUBY)
          resources :users, path: 'members', only: [:index, :show, :new, :create, :edit, :update]
        RUBY
      end

      it 'converts except for singular resource' do
        expect_offense(<<~RUBY, 'config/routes.rb')
          resource :profile, except: [:destroy]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
        RUBY

        expect_correction(<<~RUBY)
          resource :profile, only: [:show, :new, :create, :edit, :update]
        RUBY
      end
    end

    context 'nested resources' do
      it 'corrects both parent and child resources' do
        expect_offense(<<~RUBY, 'config/routes.rb')
          resources :users do
          ^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
            resources :posts
            ^^^^^^^^^^^^^^^^ Sgcop/ResourcesWithoutOnly: Use `only:` option in resource/resources routing.
          end
        RUBY

        expect_correction(<<~RUBY)
          resources :users, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
            resources :posts, only: [:index, :show, :new, :create, :edit, :update, :destroy]
          end
        RUBY
      end
    end
  end
end