# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class NoAcceptsNestedAttributesFor < Base
        MSG = 'Avoid using `accepts_nested_attributes_for`. Consider using Form Objects instead.'

        def_node_matcher :accepts_nested_attributes_for?, <<~PATTERN
          (send nil? :accepts_nested_attributes_for ...)
        PATTERN

        def on_send(node)
          return unless accepts_nested_attributes_for?(node)

          add_offense(node)
        end
      end
    end
  end
end
