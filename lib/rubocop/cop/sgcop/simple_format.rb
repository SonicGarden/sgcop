# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class SimpleFormat < Base
        MSG = 'simple_format does not escape HTML tags.'
        ESCAPE_METHODS = %i[h html_escape].freeze

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

          _receiver, method_name, *_args = *args.first
          !ESCAPE_METHODS.member?(method_name)
        end
      end
    end
  end
end
