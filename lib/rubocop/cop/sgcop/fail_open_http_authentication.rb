# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # `authenticate_with_http_token` / `authenticate_with_http_basic` の戻り値を使っていない呼び出しを検出する。
      #
      # これらのメソッドは資格情報が無い（ヘッダが無い・空）とブロックを呼ばずに nil を返すだけで、
      # リクエストを拒否しない（fail-open）。ブロック内の `else` で拒否する書き方をすると、
      # 資格情報の無いリクエストはどの分岐にも入らずに素通りする。
      #
      # 次のどれかなら警告する。
      #
      # - 戻り値を捨てている（メソッドの途中の文になっている）
      # - 同じクラスで `before_action` / `prepend_before_action` / `append_before_action` に
      #   登録したメソッドの最後の式として返している（Rails はコールバックの戻り値を見ないため）
      # - `before_action { ... }` / `before_action -> { ... }` のブロックの最後の式として返している
      # - メソッドの最後の式として返していて、同じクラスの呼び出し元のどれかが戻り値を捨てている
      #   （呼び出し元がさらにメソッドやブロックの最後の式なら、同じ判定を再帰的にたどる）
      #
      # 「最後の式」には、`if` / `unless` / `case` の分岐の最後の式や、`rescue` / `ensure` の本体も含む。
      #
      # 既知の限界:
      #
      # - `before_action` を親クラスや concern で登録している場合は、コールバックと判定できず見逃す
      # - 呼び出し元は同じクラスの中だけをたどる。concern や別クラスからの呼び出しは追わず、
      #   同じクラスに呼び出し元が無ければ警告しない
      # - 戻り値を代入していれば警告しないので、代入した値が nil のときに実際に拒否しているかまでは保証しない
      #
      # @example
      #   # bad
      #   before_action :authorize!
      #
      #   def authorize!
      #     authenticate_with_http_token do |token, _options|
      #       valid?(token) ? setup(token) : render_unauthorized
      #     end
      #   end
      #
      #   # good
      #   before_action :authenticate
      #
      #   def authenticate
      #     @current_user = authenticate_with_http_token { |token, _options| User.find_by(token:) }
      #     render_unauthorized if @current_user.nil?
      #   end
      #
      #   # good
      #   def authenticate
      #     authenticate_or_request_with_http_token { |token, _options| User.find_by(token:) }
      #   end
      class FailOpenHttpAuthentication < Base
        MSG = '`authenticate_with_http_*` は資格情報が無いとブロックを呼ばずに nil を返すだけで拒否しません。' \
              '`@current_user = authenticate_with_http_token { ... }` のように戻り値を受け取って nil のときに拒否するか、' \
              '`authenticate_or_request_with_http_*` を使ってください。'
        RESTRICT_ON_SEND = %i[authenticate_with_http_token authenticate_with_http_basic].freeze
        CALLBACK_METHODS = %i[before_action prepend_before_action append_before_action].to_set.freeze

        def_node_matcher :callback_method_names, <<~PATTERN
          (send nil? CALLBACK_METHODS $...)
        PATTERN

        # `controller.authenticate_with_http_token` のようにレシーバ付きで呼んでも fail-open なのは同じなので、
        # レシーバの有無では除外しない
        def on_send(node)
          expression = node.block_node || node
          return if expression.value_used? && !discarded_after_return?(expression)

          add_offense(node.loc.selector)
        end
        alias on_csend on_send

        private

        def discarded_after_return?(expression, visited = Set.new)
          scope = returning_scope(expression)
          return false unless scope
          return callback_block?(scope) unless scope.def_type?

          class_node = scope.each_ancestor(:class).first
          return false unless class_node

          return_value_discarded?(scope, class_node, visited)
        end

        # 同名メソッドを再定義していると、呼び出し元をたどる経路が循環しうるので visited で打ち切る
        def return_value_discarded?(def_node, class_node, visited)
          return false unless visited.add?(def_node)
          return true if callback_names(class_node).include?(def_node.method_name)

          callers(class_node, def_node.method_name).any? do |call|
            expression = call.block_node || call
            !expression.value_used? || discarded_after_return?(expression, visited)
          end
        end

        # expression を最後の式として値を返す def またはブロックを返す。
        # `&&` の右辺や途中の `return` はまず書かないので、たどらない。明示的な `begin` も、メソッド本体が
        # `begin` だけなら Style/RedundantBegin で def 直下の `rescue` に直されるので扱わない。
        def returning_scope(expression)
          node = expression
          loop do
            parent = node.parent
            return nil unless parent
            return parent if parent.def_type?
            return (parent.body.equal?(node) ? parent : nil) if parent.block_type? || parent.numblock_type?
            return nil unless last_expression_of?(parent, node)

            node = parent
          end
        end

        def last_expression_of?(parent, node)
          case parent.type
          when :begin
            parent.children.last.equal?(node)
          when :rescue, :ensure
            parent.children.first.equal?(node)
          when :if, :case
            !parent.condition.equal?(node)
          when :when
            parent.body.equal?(node)
          else
            false
          end
        end

        # `before_action { ... }` と `before_action -> { ... }` のブロックかどうか
        def callback_block?(block_node)
          send_node = block_node.lambda? ? block_node.parent : block_node.send_node
          send_node&.send_type? && callback_method_names(send_node) ? true : false
        end

        def callback_names(class_node)
          class_node.each_descendant(:send).flat_map do |send_node|
            args = callback_method_names(send_node) || []
            args.select(&:sym_type?).map(&:value)
          end
        end

        def callers(class_node, method_name)
          class_node.each_descendant(:send).select do |send_node|
            # レシーバが self 以外なら別オブジェクトのメソッドなので、この def の呼び出し元ではない
            (send_node.receiver.nil? || send_node.receiver.self_type?) && send_node.method?(method_name)
          end
        end
      end
    end
  end
end
