# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Capybara
        # SEE: https://github.com/rubocop-hq/rubocop-rails/blob/master/lib/rubocop/cop/rails/exit.rb
        class Sleep < Base
          MSG = 'Do not use `sleep` in spec.'

          def on_send(node)
            add_offense(node, location: :selector) if offending_node?(node)
          end

          private

          def offending_node?(node)
            node.method_name == :sleep && right_receiver?(node.receiver)
          end

          def right_receiver?(receiver_node)
            return true unless receiver_node

            _a, receiver_node_class, _c = *receiver_node

            receiver_node_class == :Kernel
          end
        end
      end
    end
  end
end
