# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Rspec
        # ActionMailer::TestHelperの使用を推奨する。
        class ActionMailerTestHelper < Base
          MSG = 'Use ActionMailer::TestHelper methods instead of ActionMailer::Base.deliveries.'
          MSG_SIZE_COUNT = 'Use `assert_emails(count)` instead of ActionMailer::Base.deliveries.%<method>s.'
          MSG_EMPTY = 'Use `assert_no_emails` instead of ActionMailer::Base.deliveries.empty?.'
          MSG_ANY = 'Use `assert_emails` to verify emails were sent instead of ActionMailer::Base.deliveries.any?.'
          MSG_ACCESS = 'Use `capture_emails { ... }` to access sent emails instead of ActionMailer::Base.deliveries.%<method>s.'
          MSG_HAVE_ENQUEUED_MAIL = 'Use `assert_enqueued_email_with`, `assert_enqueued_emails(count)`, ' \
                                   'or `assert_no_enqueued_emails` instead of `have_enqueued_mail`.'

          def_node_matcher :deliveries_call?, <<~PATTERN
            (send
              (const
                (const nil? :ActionMailer) :Base) :deliveries)
          PATTERN

          def_node_matcher :deliveries_method_call?, <<~PATTERN
            (send
              (send
                (const
                  (const nil? :ActionMailer) :Base) :deliveries) $...)
          PATTERN

          def_node_matcher :deliveries_array_access?, <<~PATTERN
            (send
              (send
                (const
                  (const nil? :ActionMailer) :Base) :deliveries) :[] ...)
          PATTERN

          def_node_matcher :have_enqueued_mail_matcher?, <<~PATTERN
            (send nil? :have_enqueued_mail ...)
          PATTERN

          def on_send(node)
            if deliveries_call?(node) && !node.parent&.send_type?
              add_offense(node, message: MSG)
            elsif deliveries_method_call?(node)
              check_deliveries_method(node)
            elsif have_enqueued_mail_matcher?(node)
              add_offense(node, message: MSG_HAVE_ENQUEUED_MAIL)
            end
          end

          private

          def check_deliveries_method(node)
            method_name = node.method_name
            message = message_for_method(method_name)
            add_offense(node, message:) if message
          end

          def message_for_method(method_name)
            case method_name
            when :size, :count
              format(MSG_SIZE_COUNT, method: method_name)
            when :empty?
              MSG_EMPTY
            when :any?
              MSG_ANY
            when :first, :last
              format(MSG_ACCESS, method: method_name)
            when :[]
              format(MSG_ACCESS, method: '[]')
            when :clear
              MSG
            end
          end
        end
      end
    end
  end
end
