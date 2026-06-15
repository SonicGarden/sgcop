# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # メソッド名と完全一致する引数名は、どちらを指しているのか紛らわしいので避ける。
      #
      # @example
      #   # bad
      #   def request(request)
      #   end
      #
      #   # good
      #   def request(http_request)
      #   end
      class MethodArgumentNameDuplication < Base
        MSG = 'Method name `%<name>s` and argument name `%<name>s` are identical, ' \
              'which is confusing. Rename one of them.'

        def on_def(node)
          check(node)
        end

        def on_defs(node)
          check(node)
        end

        private

        def check(node)
          method_name = node.method_name

          node.arguments.each do |arg|
            next unless arg.name == method_name

            add_offense(arg, message: format(MSG, name: method_name))
          end
        end
      end
    end
  end
end
