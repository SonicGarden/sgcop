# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # Hash#fetchのデフォルト値の適切な使用を確認する。
      class HashFetchDefault < Base
        extend AutoCorrector

        MSG = 'Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.'

        def_node_matcher :hash_element_access, <<~PATTERN
          (send $_ :[] ${sym str nil true false})
        PATTERN

        def on_or(node)
          left_node = node.lhs
          return unless hash_element_access(left_node)

          add_offense(node) do |corrector|
            hash_obj, key = hash_element_access(left_node)
            default_value = node.rhs

            corrector.replace(node, "#{hash_obj.source}.fetch(#{key.source}, #{default_value.source})")
          end
        end
      end
    end
  end
end
