# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class Unscoped < Base
        MSG = 'Do not use `unscoped`'

        def on_send(node)
          return if node.method_name != :unscoped

          add_offense(node)
        end
      end
    end
  end
end
