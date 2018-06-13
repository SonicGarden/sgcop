# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class SimpleFormat < Cop
        MSG = 'simple_format does not escape HTML tags.'

        def on_send(node)
          receiver, method_name, *args = *node
          if receiver.nil? && method_name == :simple_format && args.first&.child_nodes&.empty?
            add_offense(node)
          end
        end
      end
    end
  end
end
