# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # Hash#fetchのデフォルト値の適切な使用を確認する。
      class HashFetchDefault < Base
        extend AutoCorrector

        MSG = 'Use `Hash#fetch` with a default value instead of `||` to preserve falsey values.'

        def_node_matcher :hash_element_access, <<~PATTERN
          (send $_ :[] ${sym str nil true false})
        PATTERN

        def on_or(node)
          left_node = node.lhs
          return unless hash_element_access(left_node)

          # 同一ハッシュの複数キーへのフォールバック（`a[:x] || a[:y]`）は
          # falsey 値保持の意図ではないため対象外とする。
          # rhs がハッシュアクセスでない場合や、レシーバが異なる場合（`a[:x] || b[:y]`）は
          # falsey 値保持のパターンなので検出する。
          # なお、rhs 自体がさらに or チェーンを含む場合（`a[:x] || b || a[:z]` 等）でも、
          # ここでは node の直接の rhs だけを見て判定し、その先のチェーンは覗き見ない。
          return if same_hash_fallback?(left_node, node.rhs)

          add_offense(node) do |corrector|
            hash_obj, key = hash_element_access(left_node)
            default_value = node.rhs

            corrector.replace(node, "#{hash_obj.source}.fetch(#{key.source}, #{default_value.source})")
          end
        end

        private

        # left_node（`left_node || rhs` の lhs）と rhs が、同一レシーバへの
        # 2項のハッシュアクセスフォールバックかどうかを判定する。
        def same_hash_fallback?(left_node, rhs)
          receiver, = hash_element_access(left_node)
          other_receiver, = hash_element_access(rhs)

          !other_receiver.nil? && other_receiver == receiver
        end
      end
    end
  end
end
