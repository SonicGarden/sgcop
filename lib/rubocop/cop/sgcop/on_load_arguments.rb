# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class OnLoadArguments < Base
        MSG = 'Do not use unpermitted name as arguments for `ActiveSupport.on_load`'

        def on_send(node)
          return unless node.method_name == :on_load
          return unless node.receiver&.const_name == 'ActiveSupport'

          arguments = node.arguments
          return if arguments.empty?

          add_offense(node) unless allowed_names.include?(arguments.first.value)
        end

        private

        def allowed_names
          cop_config['AllowedNames'].map(&:to_sym)
        end
      end
    end
  end
end
