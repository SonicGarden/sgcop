# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Capybara
        class SpecStabilityCheck < Base
          MSG = 'ページの変化を伴う非同期処理後には、適切な待機処理（例: expect(page).to have_content(\'更新しました。\')）を追加してテストを安定させましょう'

          def on_block(node)
            return unless watched_method_block?(node)
            return if contains_wait_matcher?(node.body)

            add_offense(node.send_node)
          end

          private

          def watched_method_block?(node)
            watched_methods = cop_config.fetch('WatchedMethods', %w[assert_enqueued_emails])
            return false unless node.send_node&.receiver.nil?

            watched_methods.include?(node.send_node.method_name.to_s)
          end

          def contains_wait_matcher?(node)
            return false unless node

            wait_matcher_patterns = cop_config.fetch('WaitMatcherPatterns', ['^have_'])

            node.each_descendant(:send) do |send_node|
              return true if expect_to_matcher?(send_node, wait_matcher_patterns)
            end

            false
          end

          def expect_to_matcher?(send_node, wait_matcher_patterns)
            return false unless send_node.method_name == :to
            return false unless send_node.receiver&.method_name == :expect

            send_node.arguments.any? do |arg|
              next false unless arg.send_type?

              method_name = arg.method_name.to_s
              wait_matcher_patterns.any? { |pattern| method_name.match?(/#{pattern}/) }
            end
          end
        end
      end
    end
  end
end
