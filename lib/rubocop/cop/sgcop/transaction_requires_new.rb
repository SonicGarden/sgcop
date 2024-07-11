# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class TransactionRequiresNew < Base
        MSG = 'Use `requires_new: true` with `transaction` when `ActiveRecord::Rollback` is raised inside the block.'

        def_node_matcher :transaction_method?, <<~PATTERN
          (send _? :transaction ...)
        PATTERN

        def_node_search :contains_raise_active_record_rollback?, <<~PATTERN
          (send nil? :raise (const (const nil? :ActiveRecord) :Rollback))
        PATTERN

        def_node_matcher :transaction_with_requires_new?, <<~PATTERN
          (send _? :transaction (hash <(pair (sym :requires_new) (true)) ...>))
        PATTERN

        def on_block(node)
          transaction_node = node.children.first
          return unless transaction_method?(transaction_node) && contains_raise_active_record_rollback?(node)

          add_offense(transaction_node, message: MSG) unless transaction_with_requires_new?(transaction_node)
        end
      end
    end
  end
end
