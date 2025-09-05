# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class StrftimeRestriction < Base
        MSG = 'strftimeではなくI18n.lを使用してローカライズしてください。'

        def on_send(node)
          return unless node.method_name == :strftime
          return if allowed_pattern?(node)

          add_offense(node.loc.expression, message: MSG)
        end

        private

        def allowed_pattern?(node)
          return false unless node.arguments.any?

          first_argument = node.arguments.first
          return false unless first_argument.str_type?

          pattern = first_argument.value
          allowed_patterns.include?(pattern)
        end

        def allowed_patterns
          @allowed_patterns ||= cop_config['AllowedPatterns'] || []
        end
      end
    end
  end
end
