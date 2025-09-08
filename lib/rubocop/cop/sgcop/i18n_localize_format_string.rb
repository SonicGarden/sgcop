# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class I18nLocalizeFormatString < Base
        MSG = 'I18n.lのformatオプションには文字列ではなくシンボルを使用してください。ロケールファイルに定義してシンボルで参照することで、ロケールごとの切り替えが可能になります。'

        def on_send(node)
          return unless localize_method?(node)

          format_arg = extract_format_argument(node)
          return unless format_arg

          # 文字列でフォーマットが指定されている場合は警告
          if format_arg.str_type?
            add_offense(format_arg)
          end
        end

        private

        def localize_method?(node)
          # I18n.l, I18n.localize
          if node.receiver&.const_type? && node.receiver.short_name == :I18n
            %i[l localize].include?(node.method_name)
          # View helper methods: l, localize
          else
            node.receiver.nil? && %i[l localize].include?(node.method_name)
          end
        end

        def extract_format_argument(node)
          # Check if there are at least 2 arguments (object and format option)
          return nil unless node.arguments.size >= 2

          # Look for hash argument
          hash_arg = node.arguments.find(&:hash_type?)
          return nil unless hash_arg

          # Find format key in hash
          hash_arg.pairs.each do |pair|
            key = pair.key
            next unless key.sym_type? && key.value == :format

            return pair.value
          end

          nil
        end
      end
    end
  end
end
