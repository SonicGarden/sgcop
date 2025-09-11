# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class NestedResourcesWithoutModule < Base
        MSG = 'Use `module:` option in nested resource/resources routing.'

        def on_send(node)
          return unless resources_method?(node)
          return if inside_member_or_collection_block?(node)
          return unless inside_resources_block?(node)
          return if has_module_option?(node)

          add_offense(node)
        end

        private

        def inside_resources_block?(node)
          parent = node.parent
          while parent
            # Skip the immediate parent if the node has a block
            # and the parent is that block
            if parent.block_type? && parent.send_node == node
              parent = parent.parent
              next
            end

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

        def inside_member_or_collection_block?(node)
          parent = node.parent
          while parent
            if parent.block_type?
              send_node = parent.send_node
              return true if send_node&.method?(:member) || send_node&.method?(:collection)
            end

            parent = parent.parent
          end
          false
        end
      end
    end
  end
end
