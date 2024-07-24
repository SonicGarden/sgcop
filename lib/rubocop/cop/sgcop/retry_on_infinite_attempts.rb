# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class RetryOnInfiniteAttempts < Base
        MSG = 'Avoid using `Float::INFINITY` or `:unlimited` for attempts in `retry_on` method.'

        def_node_matcher :retry_on_with_infinite_attempts?, <<~PATTERN
          (send _ :retry_on _ (hash $...))
        PATTERN

        def on_send(node)
          retry_on_with_infinite_attempts?(node) do |pairs|
            pairs.each do |pair|
              key, value = *pair
              if key.value == :attempts && ((value.const_type? && value.source == 'Float::INFINITY') || (value.sym_type? && value.value == :unlimited))
                add_offense(pair)
              end
            end
          end
        end
      end
    end
  end
end
