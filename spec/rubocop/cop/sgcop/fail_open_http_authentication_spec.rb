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

      it 'before_action ではないメソッドの最後の式で、同じクラスの呼び出し元が戻り値を使っていたら警告なし' do
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

      it 'before_action ではないメソッドの最後の式で、同じクラスに呼び出し元が無ければ警告なし' do
        expect_no_offenses(<<~RUBY)
          class ApiController < ApplicationController
            def authenticate_token
              #{method_name} { |name, _| User.find_by(name: name) }
            end
          end
        RUBY
      end

      it 'メソッドの最後の式で、同じクラスの呼び出し元が戻り値を捨てていたら警告' do
        expect_offense(<<~RUBY)
          class ApiController < ApplicationController
            before_action :authenticate

            def authenticate
              authenticate_token
              log_access
            end

            def authenticate_token
              #{method_name} { |name, _| valid?(name) ? setup(name) : render_unauthorized }
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
            end
          end
        RUBY
      end

      it 'メソッドの最後の式で、呼び出し元も before_action のメソッドの最後の式なら警告' do
        expect_offense(<<~RUBY)
          class ApiController < ApplicationController
            before_action :authenticate

            def authenticate
              authenticate_token
            end

            def authenticate_token
              #{method_name} { |name, _| valid?(name) ? setup(name) : render_unauthorized }
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
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

  it '呼び出し元を複数段たどって before_action に行き着いたら警告' do
    expect_offense(<<~RUBY)
      class ApiController < ApplicationController
        before_action :authenticate

        def authenticate
          return if skip_authentication?

          current_user_from_token
        end

        def current_user_from_token
          authenticate_token
        end

        def authenticate_token
          authenticate_with_http_token { |token, _options| @current_user = User.find_by(token: token) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it '呼び出し元が複数あり、どれか 1 つでも戻り値を捨てていたら警告' do
    expect_offense(<<~RUBY)
      class ApiController < ApplicationController
        def show
          render_unauthorized unless authenticate_token
        end

        def update
          authenticate_token
          save_record
        end

        def authenticate_token
          authenticate_with_http_token { |token, _options| @current_user = User.find_by(token: token) }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it '別のクラスの呼び出し元は対象にしない' do
    expect_no_offenses(<<~RUBY)
      class AdminController < ApplicationController
        def authenticate
          authenticate_token
          log_access
        end
      end

      class ApiController < ApplicationController
        def authenticate_token
          authenticate_with_http_token { |token, _options| @current_user = User.find_by(token: token) }
        end
      end
    RUBY
  end

  it '同名メソッドを再定義していて呼び出しが循環しても停止する' do
    expect_no_offenses(<<~RUBY)
      class ApiController < ApplicationController
        def authenticate_token
          authenticate_with_http_token { |token, _options| User.find_by(token: token) }
        end

        def authenticate_token
          authenticate_token
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
