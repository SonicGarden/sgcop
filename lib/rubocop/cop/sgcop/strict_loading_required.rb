# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
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

          add_offense(value)
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
