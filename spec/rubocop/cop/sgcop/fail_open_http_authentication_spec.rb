require 'spec_helper'

describe RuboCop::Cop::Sgcop::FailOpenHttpAuthentication, :config do
  let(:msg) do
    '`authenticate_with_http_*` は資格情報が無いとブロックを呼ばずに nil を返すだけで拒否しません。' \
      '`@current_user = authenticate_with_http_token { ... }` のように戻り値を受け取って nil のときに拒否するか、' \
      '`authenticate_or_request_with_http_*` を使ってください。'
  end

  %w[authenticate_with_http_token authenticate_with_http_basic].each do |method_name|
    context "#{method_name} の場合" do
      it '戻り値を捨てていたら警告' do
        expect_offense(<<~RUBY)
          def authenticate
            #{method_name} { |name, _| @current_user = User.find_by(name: name) }
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
            log_access
          end
        RUBY
      end

      it 'before_action に登録したメソッドの最後の式なら警告' do
        expect_offense(<<~RUBY)
          class ApiController < ApplicationController
            before_action :authorize!

            def authorize!
              #{method_name} do |name, _|
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
                valid?(name) ? setup(name) : render_unauthorized
              end
            end
          end
        RUBY
      end

      it 'before_action ではないメソッドの最後の式なら警告なし' do
        expect_no_offenses(<<~RUBY)
          class ApiController < ApplicationController
            before_action :authenticate

            def authenticate
              authenticate_token || render_unauthorized
            end

            def authenticate_token
              #{method_name} { |name, _| @current_user = User.find_by(name: name) }
            end
          end
        RUBY
      end

      it '戻り値を代入していたら警告なし' do
        expect_no_offenses(<<~RUBY)
          class ApiController < ApplicationController
            before_action :authenticate

            def authenticate
              user = #{method_name} { |name, _| User.find_by(name: name) }
              render_unauthorized if user.nil?
            end
          end
        RUBY
      end

      it 'before_action のメソッドの最後で戻り値を代入していたら警告なし' do
        expect_no_offenses(<<~RUBY)
          class ApiController < ApplicationController
            before_action :authenticate

            def authenticate
              return nil if Rails.env.production?

              @current_user = #{method_name} { |name, _| User.find_by(name: name) }
            end
          end
        RUBY
      end

      it '戻り値を条件に使っていたら警告なし' do
        expect_no_offenses(<<~RUBY)
          class ApiController < ApplicationController
            before_action :authenticate

            def authenticate
              render_unauthorized unless #{method_name} { |name, _| User.find_by(name: name) }
            end
          end
        RUBY
      end
    end
  end

  it 'authenticate_or_request_with_http_token は警告なし' do
    expect_no_offenses(<<~RUBY)
      class ApiController < ApplicationController
        before_action :authenticate

        def authenticate
          authenticate_or_request_with_http_token { |token, _options| User.find_by(token: token) }
        end
      end
    RUBY
  end

  it 'authenticate_or_request_with_http_basic は警告なし' do
    expect_no_offenses(<<~RUBY)
      class ApiController < ApplicationController
        before_action :authenticate

        def authenticate
          authenticate_or_request_with_http_basic { |name, password| name == 'admin' && password == 'secret' }
        end
      end
    RUBY
  end

  it 'レシーバ付きの呼び出しは警告なし' do
    expect_no_offenses(<<~RUBY)
      def authenticate
        controller.authenticate_with_http_token { |token, _options| User.find_by(token: token) }
        log_access
      end
    RUBY
  end

  it '別の before_action で拒否していても、before_action のメソッドの最後の式なら警告' do
    expect_offense(<<~RUBY)
      class ApiController < ApplicationController
        before_action :authenticate_token
        before_action :authenticate_user!

        def authenticate_token
          return nil if Rails.env.production?

          authenticate_with_http_token do |token|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
            @current_user = User.find_signed(token, purpose: :api)
          end
        end
      end
    RUBY
  end

  it 'prepend_before_action に登録した rescue 付きメソッドの最後の式なら警告' do
    expect_offense(<<~RUBY)
      class GraphqlController < ApplicationController
        prepend_before_action :authenticate_user_by_jwt

        def authenticate_user_by_jwt
          authenticate_with_http_token do |jwt, _|
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
            @current_user = User.find_with_jwt(jwt)
            @current_user = nil if @current_user.delete_requested?
          end
        rescue JWT::ExpiredSignature
          # 期限切れの場合は何もしない
        end
      end
    RUBY
  end

  it 'rescue 付きメソッドで戻り値を受け取っていたら警告なし' do
    expect_no_offenses(<<~RUBY)
      class GraphqlController < ApplicationController
        prepend_before_action :authenticate_user_by_jwt

        def authenticate_user_by_jwt
          user = authenticate_with_http_token { |jwt, _| User.find_with_jwt(jwt) }
          @current_user = user unless user&.delete_requested?
        rescue JWT::ExpiredSignature
          # 期限切れの場合は何もしない
        end
      end
    RUBY
  end

  it 'ensure 付きの before_action のメソッドの最後の式なら警告' do
    expect_offense(<<~RUBY)
      class ApiController < ApplicationController
        before_action :authenticate

        def authenticate
          authenticate_with_http_token { |token, _options| @current_user = User.find_by(token: token) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
        ensure
          log_access
        end
      end
    RUBY
  end

  it 'append_before_action に only 付きで複数登録したメソッドの最後の式なら警告' do
    expect_offense(<<~RUBY)
      class ApiController < ApplicationController
        append_before_action :set_locale, :authenticate, only: :index

        def authenticate
          authenticate_with_http_basic { |name, _password| @current_user = User.find_by(name: name) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it '別のクラスの before_action に登録された同名メソッドは対象にしない' do
    expect_no_offenses(<<~RUBY)
      class AdminController < ApplicationController
        before_action :authenticate
      end

      class ApiController < ApplicationController
        def authenticate
          authenticate_with_http_token { |token, _options| @current_user = User.find_by(token: token) }
        end
      end
    RUBY
  end
end
