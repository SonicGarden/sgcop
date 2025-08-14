# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class NestedResourcesWithoutModule < Base
        MSG = 'Use `module:` option in nested resource/resources routing.'

        def on_send(node)
          return unless resources_method?(node)
          return unless inside_resources_block?(node)
          return if has_module_option?(node)
          return if node.parent&.block_type? && node.parent.send_node == node

          add_offense(node)
        end

        private

        def inside_resources_block?(node)
          parent = node.parent
          while parent
            if parent.block_type? && resources_method?(parent.send_node)
              return true
            end

            parent = parent.parent
          end
          false
        end

        def resources_method?(node)
          return false unless node

          node.method?(:resource) || node.method?(:resources)
        end

        def has_module_option?(node)
          node.each_child_node(:hash) do |hash_node|
            hash_node.each_pair do |key_node, _value_node|
              next unless key_node.sym_type?

              return true if %i[module namespace scope].include?(key_node.value)
            end
          end

          false
        end
      end
    end
  end
end
