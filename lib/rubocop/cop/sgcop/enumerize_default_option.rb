# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class EnumerizeDefaultOption < Base
        MSG = 'Do not use `default` option in `enumerize`. Use database-level default values instead.'

        def_node_matcher :enumerize_with_default?, <<~PATTERN
          (send _ :enumerize ... (hash $...))
        PATTERN

        def on_send(node)
          enumerize_with_default?(node) do |pairs|
            pairs.each do |pair|
              key, _value = *pair
              if key.sym_type? && key.value == :default
                add_offense(pair)
              end
            end
          end
        end
      end
    end
  end
end
