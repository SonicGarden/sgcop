module RuboCop
  module Cop
    module Rails
      class MissingDependent < Cop
        def on_send(node)
          receiver, _method_name, *_args = *node
          check_method_node(node) if receiver.nil?
        end

        private

        def check_method_node(node)
          _receiver, method_name, *args = *node
          return unless offending_method?(method_name)
          return if args.size > 0 && args.last.type == :hash && hash_has_key?(args.last)
          add_offense(node, :selector, "#{method_name} に dependent がありません", :warning)
        end

        def hash_has_key?(node)
          node.child_nodes.any? do |pair|
            key = pair.child_nodes.first
            key.type == :sym && key.children.first == :dependent
          end
        end

        def offending_method?(method_name)
          %i(has_one has_many).member?(method_name)
        end
      end
    end
  end
end
