# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # 特定のビューヘルパーメソッドの使用を制限する（設定でカスタマイズ可能）。
      class RestrictedViewHelpers < Base
        def on_send(node)
          return if restricted_methods.empty?
          return unless node.receiver.nil?

          method_name = node.method_name.to_s
          return unless restricted_methods.key?(method_name)

          message = restricted_methods[method_name]
          add_offense(node, message:)
        end

        private

        def restricted_methods
          @restricted_methods ||= cop_config.fetch('RestrictedMethods', {})
        end
      end
    end
  end
end
