# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class StrftimeRestriction < Base
        MSG = 'strftimeではなくI18n.lを使用してローカライズしてください。'

        def on_send(node)
          return unless node.method_name == :strftime

          add_offense(node.loc.expression, message: MSG)
        end
      end
    end
  end
end
