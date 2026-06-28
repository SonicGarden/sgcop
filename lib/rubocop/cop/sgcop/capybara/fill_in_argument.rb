# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Capybara
        # `fill_in` の第1引数（locator）を、ラベルテキストか name 属性のどちらかに統一する。
        #
        # Capybara の `fill_in` の locator は実行時に id → name → placeholder → label の
        # 順で総当たりマッチされるため、文字列だけから「ラベルか name 属性か」を確実に
        # 判別することはできない。そこで Rails のフォームヘルパが生成する name 属性の
        # 特徴（`model[attr]` 形式 / snake_case）と、ラベルらしい特徴（日本語などの非
        # ASCII / 空白を含む人間可読テキスト）から「明らかにどちらか」のケースだけを
        # 保守的に検出する。どちらとも取れる曖昧な文字列（`email` 等の単純な英単語）は
        # 警告しない。
        #
        # @example EnforcedStyle: label (default)
        #   # bad
        #   fill_in 'user[email]', with: 'x'
        #   fill_in 'first_name', with: 'x'
        #
        #   # good
        #   fill_in 'メールアドレス', with: 'x'
        #
        # @example EnforcedStyle: name
        #   # bad
        #   fill_in 'メールアドレス', with: 'x'
        #
        #   # good
        #   fill_in 'user[email]', with: 'x'
        #
        class FillInArgument < Base
          include ConfigurableEnforcedStyle

          MSG_PREFER_LABEL = 'fill_in の引数はラベルテキストで統一しよう（name属性ではなく）。'
          MSG_PREFER_NAME = 'fill_in の引数はname属性で統一しよう（ラベルテキストではなく）。'

          RESTRICT_ON_SEND = %i[fill_in].freeze

          def on_send(node)
            arg = node.first_argument
            return unless arg&.str_type?

            value = arg.value

            case style
            when :label
              add_offense(arg, message: MSG_PREFER_LABEL) if name_attribute_like?(value)
            when :name
              add_offense(arg, message: MSG_PREFER_NAME) if label_like?(value)
            end
          end
          alias on_csend on_send

          private

          # 明らかに Rails の name 属性とみなせる文字列か。
          # - 角括弧を含む name 形式（user[email], post[author][name]）
          # - アンダースコアを含む snake_case（first_name）
          # 単純な小文字英単語（email 等）はラベルにもなり得るため除外する（保守的）。
          def name_attribute_like?(value)
            value.match?(/\A\w+(\[\w+\])+\z/) ||
              value.match?(/\A[a-z][a-z0-9]*(_[a-z0-9]+)+\z/)
          end

          # 明らかにラベルテキストとみなせる文字列か。
          # - 非 ASCII（日本語など）を含む
          # - 空白を含む人間可読フレーズ
          def label_like?(value)
            value.match?(/[^\x00-\x7F]/) || value.match?(/\s/)
          end
        end
      end
    end
  end
end
