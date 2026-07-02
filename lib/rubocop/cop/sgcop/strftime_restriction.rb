# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class StrftimeRestriction < Base
        MSG = 'strftimeではなくI18n.lを使用してローカライズしてください。'

        # 指定子(%Y, %-d, %3N, %EY, %::z, %% 等)と区切り記号(- / : . 空白)のみで
        # 構成されるフォーマットは許容する。年・月・日などのリテラル単語が混ざる場合は
        # ロケール対応のため I18n.l を使うべきなので警告する。
        ALLOWED_FORMAT_REGEXP = %r{
          \A
          (?:
            %%
            |
            %[-_0^#+]*(?::{1,3})?\d*[EO]?[A-Za-z]
            |
            [-/:.\s]
          )*
          \z
        }x

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
          ALLOWED_FORMAT_REGEXP.match?(pattern) || allowed_patterns.include?(pattern)
        end

        def allowed_patterns
          @allowed_patterns ||= cop_config.fetch('AllowedPatterns', [])
        end
      end
    end
  end
end
