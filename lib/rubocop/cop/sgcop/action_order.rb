# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class ActionOrder < Base
        extend AutoCorrector

        MSG = 'Controller actions should be ordered: index, show, new, create, edit, update, destroy.'
        EXPECTED_ORDER = %i[index show new create edit update destroy].freeze

        def on_class(node)
          return unless controller_class?(node)

          action_nodes = extract_action_nodes(node)
          return if action_nodes.empty?
          return if actions_in_correct_order?(action_nodes.map(&:method_name))

          add_offense(node) do |corrector|
            correct_action_order(corrector, node, action_nodes)
          end
        end

        private

        def controller_class?(node)
          return false unless node.identifier

          node.identifier.source.end_with?('Controller')
        end

        def extract_action_nodes(node)
          return [] unless node.body

          method_nodes = if node.body.begin_type?
                           node.body.children.select(&:def_type?)
                         else
                           node.body.def_type? ? [node.body] : []
                         end

          method_nodes.select do |method_node|
            EXPECTED_ORDER.include?(method_node.method_name)
          end
        end

        def actions_in_correct_order?(actions)
          expected_indices = actions.map { |action| EXPECTED_ORDER.index(action) }
          expected_indices == expected_indices.sort
        end

        def correct_action_order(corrector, class_node, action_nodes)
          return if action_nodes.empty?

          sorted_actions = action_nodes.sort_by { |node| EXPECTED_ORDER.index(node.method_name) }
          action_nodes.each_with_index do |original_node, index|
            corrected_node = sorted_actions[index]
            next if original_node == corrected_node

            corrector.replace(original_node, corrected_node.source)
          end
        end
      end
    end
  end
end
