# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class ResourcesWithoutOnly < Base
        MSG = 'Use `only:` option in resource/resources routing.'

        def on_send(node)
          return unless resources_method?(node)
          return if has_only_option?(node)

          add_offense(node)
        end

        private

        def resources_method?(node)
          node.method?(:resource) || node.method?(:resources)
        end

        def has_only_option?(node)
          node.each_child_node(:hash) do |hash_node|
            hash_node.each_pair do |key_node, _value_node|
              next unless key_node.sym_type?

              return true if key_node.value == :only
            end
          end

          false
        end
      end
    end
  end
end