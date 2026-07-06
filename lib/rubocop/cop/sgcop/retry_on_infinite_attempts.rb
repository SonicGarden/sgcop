# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # retry_onでの無限リトライを防止する。
      class RetryOnInfiniteAttempts < Base
        MSG = 'Avoid using `Float::INFINITY` or `:unlimited` for attempts in `retry_on` method.'

        def_node_matcher :retry_on_with_infinite_attempts?, <<~PATTERN
          (send _ :retry_on ... (hash $...))
        PATTERN

        def on_send(node)
          retry_on_with_infinite_attempts?(node) do |pairs|
            pairs.each do |pair|
              key, value = *pair
              infinite_value = (value.const_type? && value.source == 'Float::INFINITY') ||
                               (value.sym_type? && value.value == :unlimited)
              add_offense(pair) if key.value == :attempts && infinite_value
            end
          end
        end
      end
    end
  end
end
