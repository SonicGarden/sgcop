# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # N+1問題を防ぐstrict_loadingの使用を推奨する。
      #
      # 同名変数への再代入（`@users = @users.preload(:posts)`）は、同じスコープ
      # （def/ブロック/クラス・モジュール本体、またはトップレベル）内で先行する
      # 同名変数への代入を遡り、その右辺に`strict_loading`または
      # `includes`/`preload`が含まれる場合のみ除外する。起点の代入はこのCop自身が
      # 既に検査しているため、再代入まで警告すると`strict_loading`を二重に
      # 書かせることになるため。
      #
      # `@users = @users.where(...)`のように目印のない自己再代入は、さらに前の
      # 代入へ遡る。先行する代入が見つからない場合や、起点に目印がない場合
      # （`users = User.all` の後の `users = users.includes(:posts)`）は警告する。
      # 別スコープの代入（`before_action`で設定したインスタンス変数や、
      # ブロックの外側での代入）は遡らない。
      #
      # 制御フローは考慮せず、ソース上で直前にある代入のみを起点とみなす。
      # `if`/`else`で分岐して代入している場合はソース上の直前の分岐だけを見る。
      # `||=`や多重代入を起点とする場合は遡らずに警告する。
      # ブロック境界の扱いはRubyのクロージャ意味論より厳しいが、意図的な割り切り。
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
          return if self_reassignment?(value, node.name) && exempt_self_reassignment?(node)

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

        # 右辺チェーンの根が代入先と同名の変数参照か（自己再代入か）を判定する。
        def self_reassignment?(value, name)
          same_variable?(root_receiver(value), name)
        end

        # 自己再代入が除外対象かを判定する。
        # 同一スコープ内の直前の同名代入を遡り、右辺に`strict_loading`または
        # `includes`/`preload`が含まれていれば除外する。目印のない自己再代入
        # （`@s = @s.where(...)`）はさらに前の代入へ遡る。
        def exempt_self_reassignment?(node)
          scope = enclosing_scope(node)
          current = node

          loop do
            origin = preceding_assignment(current, scope)
            return false unless origin

            rhs = origin.expression
            return false unless rhs
            return true if contains_strict_loading?(rhs) || contains_includes_or_preload?(rhs)
            return false unless self_reassignment?(rhs, node.name)

            current = origin
          end
        end

        def enclosing_scope(node)
          node.each_ancestor(:any_def, :any_block, :class, :module, :sclass).first || processed_source.ast
        end

        def preceding_assignment(node, scope)
          candidates =
            scope.each_descendant(node.type).select do |candidate|
              preceding_candidate?(candidate, node, scope)
            end
          candidates.max_by { |candidate| candidate.source_range.begin_pos }
        end

        def preceding_candidate?(candidate, node, scope)
          candidate.name == node.name &&
            candidate.source_range.begin_pos < node.source_range.begin_pos &&
            enclosing_scope(candidate).equal?(scope)
        end
      end
    end
  end
end
