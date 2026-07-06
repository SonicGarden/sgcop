# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Rspec
        # 子コンテキストで親のlet/let!/subjectをオーバーライドすることを検出し、
        # 各コンテキストで独立に定義することを推奨する。
        #
        # ネスト階層をまたぐオーバーライドは保守を混乱させバグを生むため、
        # 子で別の値が必要なら親の宣言を上書きせず独立した名前で定義する。
        # （同一example group内の重複はRSpec/OverwritingSetupが担当するため、
        # 本Copは親より上の祖先のみを探索して二重報告を避ける）
        class NoLetOverride < Base
          MSG = '`%<name>s` is already defined in a parent context. ' \
                'Define it independently instead of overriding.'

          def_node_matcher :setup_definition?, <<~PATTERN
            (block
              (send nil? {:let :let! :subject} (sym $_))
              ...)
          PATTERN

          def_node_matcher :example_group?, <<~PATTERN
            (block
              (send nil? {:describe :context :xdescribe :xcontext :fdescribe :fcontext :feature :shared_examples :shared_context} ...)
              ...)
          PATTERN

          def on_block(node)
            name = setup_definition?(node)
            return unless name
            return unless defined_in_ancestor?(name, node)

            add_offense(node, message: format(MSG, name:))
          end

          private

          # 同一example group内の兄弟重複はRSpec/OverwritingSetupの担当なので、
          # 自分を内包する一番近いexample groupの外側（親のexample group）以上のみを探索する。
          def defined_in_ancestor?(name, block_node)
            group_node = enclosing_example_group(block_node)
            return false unless group_node

            parent_node = group_node.parent
            while parent_node
              parent_node.each_child_node do |child|
                return true if setup_definition?(child) == name
              end
              parent_node = parent_node.parent
            end
            false
          end

          def enclosing_example_group(block_node)
            node = block_node.parent
            node = node.parent while node && !example_group?(node)
            node
          end
        end
      end
    end
  end
end
