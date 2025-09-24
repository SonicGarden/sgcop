# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Rspec
        class NoVariableExpectation < Base
          MSG = 'Use literal values instead of variables in expectations. Use "%<matcher>s" with literal values.'

          def on_send(node)
            return unless expectation_call?(node)

            matcher_node = node.arguments.first
            return unless matcher_node&.send_type?

            matcher_name = matcher_node.method_name.to_s
            return unless target_matchers.include?(matcher_name)

            check_matcher_arguments(matcher_node, matcher_name)
          end

          private

          def check_matcher_arguments(matcher_node, matcher_name)
            matcher_node.arguments.each do |arg|
              next if literal_value?(arg)
              next if allowed_method?(arg)

              add_offense(arg, message: format(MSG, matcher: matcher_name))
            end
          end

          def expectation_call?(node)
            %i[to not_to to_not].include?(node.method_name) &&
              node.receiver&.send_type? &&
              node.receiver.method_name == :expect
          end

          def literal_value?(node)
            return true if node.nil?

            simple_literal?(node) || complex_literal?(node)
          end

          def simple_literal?(node)
            %i[str sym int float true false nil regexp].include?(node.type)
          end

          def complex_literal?(node)
            case node.type
            when :array
              all_children_literal?(node)
            when :hash
              all_hash_pairs_literal?(node)
            else
              false
            end
          end

          def all_children_literal?(node)
            node.children.all? { |child| literal_value?(child) }
          end

          def all_hash_pairs_literal?(node)
            node.children.all? do |pair|
              pair.children.all? { |child| literal_value?(child) }
            end
          end

          def allowed_method?(node)
            return false unless node.send_type?

            method_name = build_method_call_string(node)
            allowed_methods.include?(method_name)
          end

          def build_method_call_string(node)
            return node.method_name.to_s if node.receiver.nil?

            if node.receiver.const_type?
              "#{node.receiver.const_name}.#{node.method_name}"
            elsif node.receiver.send_type?
              "#{build_method_call_string(node.receiver)}.#{node.method_name}"
            else
              node.method_name.to_s
            end
          end

          def target_matchers
            cop_config['TargetMatchers'] || []
          end

          def allowed_methods
            cop_config['AllowedMethods'] || []
          end
        end
      end
    end
  end
end
