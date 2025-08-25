# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class RestrictedViewHelpers < Base
        def on_send(node)
          return if restricted_methods.empty?
          return unless node.receiver.nil?

          method_name = node.method_name.to_s
          return unless restricted_methods.key?(method_name)

          message = restricted_methods[method_name]
          add_offense(node, message: message)
        end

        private

        def restricted_methods
          @restricted_methods ||= cop_config['RestrictedMethods'] || {}
        end
      end
    end
  end
end
