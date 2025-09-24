# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Rspec
        class ConditionalExample < Base
          MSG = 'Avoid conditional expectations. Always assert expectations unconditionally.'

          def on_if(node)
            # elsif節がある場合は検出しない（複雑な条件分岐）
            return if node.elsif?
            # else節がある場合も検出しない（if/else, unless/elseなど）
            return if node.else_branch

            # 修飾子形式でもブロック形式でも、if_branchにexpectがあれば検出
            add_offense(node) if contains_expect?(node.if_branch)
          end

          private

          def contains_expect?(node)
            return false unless node

            # expectを直接呼んでいるか、子ノードにexpectがあるかをチェック
            expect_call?(node) || check_children_for_expect(node)
          end

          def check_children_for_expect(node)
            return false unless node.is_a?(RuboCop::AST::Node)

            node.each_child_node.any? { |child| contains_expect?(child) }
          end

          def expect_call?(node)
            node.send_type? && node.method_name == :expect && node.receiver.nil?
          end
        end
      end
    end
  end
end
