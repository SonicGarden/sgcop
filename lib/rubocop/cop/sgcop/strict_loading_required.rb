# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # N+1問題を防ぐstrict_loadingの使用を推奨する。
      #
      # 同名変数への再代入（`@users = @users.preload(:posts)`）は除外する。
      # 絞り込みの起点となる最初の代入をこのCop自身が既に検査しているため、
      # 同じ変数を絞り込む再代入まで警告すると`strict_loading`を二重に
      # 書かせることになるため。別名への代入は新たな起点とみなし検査する。
      #
      # この割り切りにより、起点に`includes`/`preload`がない場合
      # （`users = User.all` の後の `users = users.includes(:posts)`）は
      # 警告されなくなる。`strict_loading`は起点で付ける方針とする。
      class StrictLoadingRequired < Base
        MSG = 'Add `.strict_loading` when using `includes` or `preload` with variable assignment'

        def_node_matcher :variable_assignment?, <<~PATTERN
          ({lvasgn ivasgn cvasgn gvasgn} _ $_)
        PATTERN

        def_node_matcher :includes_or_preload_call?, <<~PATTERN
          (send _ {:includes :preload} ...)
        PATTERN

        def_node_matcher :strict_loading_call?, <<~PATTERN
          (send _ :strict_loading ...)
        PATTERN

        def_node_matcher :same_variable?, <<~PATTERN
          ({lvar ivar cvar gvar} %1)
        PATTERN

        def on_lvasgn(node)
          check_assignment(node)
        end

        def on_ivasgn(node)
          check_assignment(node)
        end

        def on_cvasgn(node)
          check_assignment(node)
        end

        def on_gvasgn(node)
          check_assignment(node)
        end

        private

        def check_assignment(node)
          value = variable_assignment?(node)
          return unless value

          return unless contains_includes_or_preload?(value)
          return if contains_strict_loading?(value)
          return if same_variable?(root_receiver(value), node.name)

          add_offense(value)
        end

        def root_receiver(node)
          return node unless node.send_type?

          receiver = node.receiver
          return nil if receiver.nil?

          root_receiver(receiver)
        end

        def contains_includes_or_preload?(node)
          return false unless node.is_a?(RuboCop::AST::Node)

          if includes_or_preload_call?(node)
            true
          elsif node.send_type?
            contains_includes_or_preload?(node.receiver)
          else
            false
          end
        end

        def contains_strict_loading?(node)
          return false unless node.is_a?(RuboCop::AST::Node)

          if strict_loading_call?(node)
            true
          elsif node.send_type?
            contains_strict_loading?(node.receiver)
          else
            false
          end
        end
      end
    end
  end
end
