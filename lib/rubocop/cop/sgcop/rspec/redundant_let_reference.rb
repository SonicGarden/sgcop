# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Rspec
        class RedundantLetReference < Base
          MSG_BEFORE = 'Use `let!` instead of referencing `let` in `before` block, or move the setup directly into `before`.'
          MSG_IT = 'Use `let!` for eager evaluation or move the setup directly into the test block instead of just referencing `let`.'

          def_node_matcher :before_block?, <<~PATTERN
            (block
              (send nil? :before ...)
              ...
              $_)
          PATTERN

          def_node_matcher :it_block?, <<~PATTERN
            (block
              (send nil? {:it :specify :example} ...)
              ...
              $_)
          PATTERN

          def_node_matcher :let_definition?, <<~PATTERN
            (block
              (send nil? {:let :let!} (sym $_))
              ...)
          PATTERN

          def on_block(node)
            if (body = before_block?(node))
              check_block_body(body, node, MSG_BEFORE)
            elsif (body = it_block?(node))
              check_block_body(body, node, MSG_IT)
            end
          end

          private

          def check_block_body(body_node, block_node, message)
            return unless body_node

            if body_node.begin_type?
              body_node.children.each do |child_node|
                check_single_statement(child_node, block_node, message)
              end
            else
              check_single_statement(body_node, block_node, message)
            end
          end

          def check_single_statement(node, block_node, message)
            return unless node.send_type? && node.receiver.nil? && node.arguments.empty?

            variable_name = node.method_name
            return unless let_variable_defined?(variable_name, block_node)

            add_offense(node, message: message)
          end

          def let_variable_defined?(variable_name, block_node)
            parent_node = block_node.parent
            while parent_node
              parent_node.each_child_node do |child|
                if let_definition?(child) == variable_name
                  return true
                end
              end
              parent_node = parent_node.parent
            end
            false
          end
        end
      end
    end
  end
end
