# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class EnumerizePredicatesOption < Base
        MSG = 'Do not use `predicates` option in `enumerize`.'
        MSG_WITH_PREFIX = 'Use `predicates: { prefix: true }` instead of `predicates: %<value>s`.'

        def_node_matcher :enumerize_with_predicates?, <<~PATTERN
          (send _ :enumerize ... (hash $...))
        PATTERN

        def on_send(node)
          enumerize_with_predicates?(node) do |pairs|
            pairs.each do |pair|
              key, value = *pair
              next unless key.sym_type? && key.value == :predicates

              if should_register_offense?(value)
                message = offense_message(value)
                add_offense(pair, message: message)
              end
            end
          end
        end

        private

        def should_register_offense?(value_node)
          return true if value_node.true_type? || value_node.false_type?

          return true unless value_node.hash_type?
          return false if allow_with_prefix? && has_prefix_option?(value_node)

          true
        end

        def offense_message(value_node)
          if allow_with_prefix? && value_node.true_type?
            format(MSG_WITH_PREFIX, value: value_node.source)
          else
            MSG
          end
        end

        def has_prefix_option?(hash_node)
          hash_node.pairs.any? do |pair|
            key, value = *pair
            key.sym_type? && key.value == :prefix && value.true_type?
          end
        end

        def allow_with_prefix?
          cop_config.fetch('AllowWithPrefix', false)
        end
      end
    end
  end
end
