# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Rspec
        class RedundantPerformEnqueuedJobs < Base
          MSG = '`%<method>s` internally uses `perform_enqueued_jobs`, so the outer `perform_enqueued_jobs` is redundant.'

          def_node_matcher :perform_enqueued_jobs_block?, <<~PATTERN
            (block
              (send nil? :perform_enqueued_jobs ...)
              ...
              $_)
          PATTERN

          def_node_matcher :action_mailer_test_helper_method?, <<~PATTERN
            (block
              (send nil? {:capture_emails :deliver_enqueued_emails :assert_emails :assert_no_emails} ...)
              ...)
          PATTERN

          def_node_matcher :action_mailer_test_helper_method_call?, <<~PATTERN
            (send nil? {:capture_emails :deliver_enqueued_emails :assert_emails :assert_no_emails} ...)
          PATTERN

          def on_block(node)
            return unless perform_enqueued_jobs_block?(node)

            block_body = perform_enqueued_jobs_block?(node)
            check_for_redundant_calls(block_body, node)
          end

          private

          def check_for_redundant_calls(body_node, parent_node)
            return unless body_node

            body_node.each_descendant do |descendant|
              if action_mailer_test_helper_method?(descendant)
                method_name = descendant.send_node.method_name
                next unless method_with_perform_enqueued_jobs?(method_name, descendant)

                add_offense(
                  descendant.send_node,
                  message: format(MSG, method: method_name)
                )
              elsif action_mailer_test_helper_method_call?(descendant)
                method_name = descendant.method_name
                next unless method_with_perform_enqueued_jobs?(method_name, descendant)

                add_offense(
                  descendant,
                  message: format(MSG, method: method_name)
                )
              end
            end
          end

          def method_with_perform_enqueued_jobs?(method_name, node)
            case method_name
            when :capture_emails, :deliver_enqueued_emails
              true
            when :assert_emails, :assert_no_emails
              node.block_type? || node.block_literal?
            else
              false
            end
          end
        end
      end
    end
  end
end
