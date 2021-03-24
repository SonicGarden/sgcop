# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class SimpleFormAssociation < Base
        MSG = 'Specify the `collection` option'

        def_node_matcher :has_association_call?, <<~PATTERN
          (block
            (send _ {:simple_form_for | :simple_fields_for | :simple_nested_form_for} ...)
            (args (arg _f))
            `$(send (lvar _f) :association $...))
        PATTERN

        def_node_matcher :has_collection_option?, <<~PATTERN
          (hash <(pair (sym :collection) _) ...>)
        PATTERN

        def on_block(node)
          match = has_association_call?(node)
          return if match.nil?

          send_node, args_node = match
          return if args_node.any? { |nd| has_collection_option?(nd) }

          add_offense(send_node)
        end
      end
    end
  end
end
