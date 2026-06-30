# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class FormLabelFirstArgument < Base
        MSG = 'f.label の第一引数には属性名(Symbol)を渡してください。' \
              'ラベルテキストは第二引数に渡します(例: `f.label :name, t("...")`)。'

        FORM_BUILDER_NAMES = %i[f ff fff form].freeze

        # receiver あり ＆ メソッド名 label ＆ 第一引数を捕捉。
        # 引数ゼロはマッチしない(第一引数の捕捉が必須)。
        def_node_matcher :form_label_call?, <<~PATTERN
          (send $_ :label $_ ...)
        PATTERN

        def on_send(node)
          form_label_call?(node) do |receiver, first_arg|
            return unless form_builder_receiver?(receiver)
            return unless text_like?(first_arg)

            add_offense(first_arg)
          end
        end

        private

        # `f` / `form` 等のブロック変数(lvar)か、レシーバ無しメソッド呼び出し(send nil? :f)に限定
        def form_builder_receiver?(receiver)
          return false if receiver.nil?

          name =
            if receiver.lvar_type?
              receiver.children.first
            elsif receiver.send_type? && receiver.receiver.nil?
              receiver.method_name
            end

          FORM_BUILDER_NAMES.include?(name)
        end

        # 「明らかにテキスト」のみ警告対象にする。
        # 変数・メソッド戻り値(lvar/send/ivar 等)は Symbol を返す可能性があるため見逃す。
        def text_like?(arg)
          arg.str_type? || arg.dstr_type? || translation_call?(arg)
        end

        def translation_call?(arg)
          return false unless arg.send_type?

          %i[t translate].include?(arg.method_name) &&
            (arg.receiver.nil? || i18n_receiver?(arg.receiver))
        end

        def i18n_receiver?(receiver)
          receiver.const_type? && receiver.short_name == :I18n
        end
      end
    end
  end
end
