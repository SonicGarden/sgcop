# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class ErrorMessageFormat < Base
        MSG = 'Error message should be a symbol.'

        def on_send(node)
          check_validates_message(node)
          check_errors_add(node)
        end

        private

        def check_validates_message(node)
          return unless node.method_name == :validates

          find_message_in_validates(node)
        end

        def find_message_in_validates(node)
          node.arguments.each do |arg|
            next unless arg.hash_type?

            check_validation_options(node, arg)
          end
        end

        def check_validation_options(node, hash_arg)
          hash_arg.each_pair do |_key, value|
            next unless value.hash_type?

            check_message_option(node, value)
          end
        end

        def check_message_option(node, options_hash)
          options_hash.each_pair do |opt_key, opt_value|
            next unless message_key?(opt_key)
            next if opt_value.sym_type?

            add_offense(node)
          end
        end

        def message_key?(key_node)
          key_node.sym_type? && key_node.value == :message
        end

        def check_errors_add(node)
          return unless errors_add_call?(node)

          message_arg = node.arguments[1]
          add_offense(node) if message_arg && !message_arg.sym_type?
        end

        def errors_add_call?(node)
          node.method_name == :add &&
            node.receiver&.send_type? &&
            node.receiver.method_name == :errors
        end
      end
    end
  end
end
