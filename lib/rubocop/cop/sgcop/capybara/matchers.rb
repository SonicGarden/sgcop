# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Capybara
        # SEE: https://github.com/rubocop-hq/rubocop/blob/v1.0.0/lib/rubocop/cop/style/string_methods.rb
        class Matchers < Base
          include MethodPreference
          extend AutoCorrector

          MSG = 'Prefer `%<prefer>s` over `%<current>s`.'

          def on_send(node)
            return unless (preferred_method = preferred_method(node.method_name))

            message = format(MSG, prefer: preferred_method, current: node.method_name)

            add_offense(node.loc.selector, message: message) do |corrector|
              corrector.replace(node.loc.selector, preferred_method(node.method_name))
            end
          end
          alias on_csend on_send
        end
      end
    end
  end
end
