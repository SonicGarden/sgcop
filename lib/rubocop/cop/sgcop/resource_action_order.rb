# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class ResourceActionOrder < Base
        extend AutoCorrector

        MSG = 'Actions should be ordered in the same sequence as Rails/ActionOrder: %<expected_order>s'

        EXPECTED_ORDER = %i[index show new edit create update destroy].freeze

        def on_send(node)
          return unless resource_method?(node)

          actions = extract_actions(node)
          return if actions.empty?

          expected_actions = sort_actions(actions)
          return if actions == expected_actions

          add_offense(
            node,
            message: format(MSG, expected_order: expected_actions.join(', '))
          ) do |corrector|
            autocorrect(corrector, node, expected_actions)
          end
        end

        private

        def resource_method?(node)
          node.method?(:resource) || node.method?(:resources)
        end

        def extract_actions(node)
          actions = []

          node.each_child_node(:hash) do |hash_node|
            hash_node.each_pair do |key_node, value_node|
              next unless key_node.sym_type?

              case key_node.value
              when :only, :except
                actions.concat(extract_action_symbols(value_node))
              end
            end
          end

          actions.uniq
        end

        def extract_action_symbols(node)
          case node.type
          when :array
            node.children.filter_map { |child| child.value if child.sym_type? }
          when :sym
            [node.value]
          else
            []
          end
        end

        def sort_actions(actions)
          actions.sort_by { |action| EXPECTED_ORDER.index(action) || Float::INFINITY }
        end

        def autocorrect(corrector, node, expected_actions)
          node.each_child_node(:hash) do |hash_node|
            hash_node.each_pair do |key_node, value_node|
              next unless key_node.sym_type?

              case key_node.value
              when :only, :except
                correct_action_list(corrector, value_node, expected_actions)
              end
            end
          end
        end

        def correct_action_list(corrector, node, actions)
          case node.type
          when :array
            new_content = build_array_content(actions, node)
            corrector.replace(node, new_content)
          when :sym
            corrector.replace(node, ":#{actions.first}") if actions.size == 1
          end
        end

        def build_array_content(actions, node)
          if percent_array?(node)
            "%i[#{actions.join(' ')}]"
          else
            action_strings = actions.map { |action| ":#{action}" }
            "[#{action_strings.join(', ')}]"
          end
        end

        def percent_array?(node)
          node.source.start_with?('%i')
        end
      end
    end
  end
end
