# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class SimpleFormat < Cop
        MSG = 'simple_format does not escape HTML tags.'

        def on_send(node)
          receiver, method_name, *args = *node
          if receiver.nil? && method_name == :simple_format && warning_args?(args)
            add_offense(node)
          end
        end

        private

        def warning_args?(args)
          return false if args.first.nil?
          return true if args.first.child_nodes.empty?

          receiver, *_args = *args.first
          !receiver.nil?
        end
      end
    end
  end
end
