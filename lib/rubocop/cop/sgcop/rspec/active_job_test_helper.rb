# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Rspec
        class ActiveJobTestHelper < Base
          MSG = 'Use ActiveJob::TestHelper methods instead of RSpec ActiveJob matchers.'
          MSG_HAVE_ENQUEUED_JOB = 'Use `assert_enqueued_jobs(count)` or `assert_enqueued_with` instead of `%<matcher>s`.'
          MSG_HAVE_BEEN_ENQUEUED = 'Use `assert_enqueued_with` instead of `%<matcher>s`.'
          MSG_ENQUEUE_JOB = 'Use `assert_enqueued_jobs` with a block instead of `%<matcher>s`.'
          MSG_HAVE_PERFORMED_JOB = 'Use `assert_performed_jobs(count)` or `assert_performed_with` instead of `%<matcher>s`.'
          MSG_HAVE_BEEN_PERFORMED = 'Use `assert_performed_with` instead of `%<matcher>s`.'
          MSG_PERFORM_JOB = 'Use `assert_performed_jobs` with a block instead of `%<matcher>s`.'

          def_node_matcher :active_job_matcher?, <<~PATTERN
            (send nil? ${:have_enqueued_job :have_been_enqueued :enqueue_job
                         :have_performed_job :have_been_performed :perform_job} ...)
          PATTERN

          def on_send(node)
            active_job_matcher?(node) do |matcher_name|
              message = message_for_matcher(matcher_name)
              add_offense(node, message: message)
            end
          end

          private

          def message_for_matcher(matcher_name)
            case matcher_name
            when :have_enqueued_job
              format(MSG_HAVE_ENQUEUED_JOB, matcher: 'have_enqueued_job')
            when :have_been_enqueued
              format(MSG_HAVE_BEEN_ENQUEUED, matcher: 'have_been_enqueued')
            when :enqueue_job
              format(MSG_ENQUEUE_JOB, matcher: 'enqueue_job')
            when :have_performed_job
              format(MSG_HAVE_PERFORMED_JOB, matcher: 'have_performed_job')
            when :have_been_performed
              format(MSG_HAVE_BEEN_PERFORMED, matcher: 'have_been_performed')
            when :perform_job
              format(MSG_PERFORM_JOB, matcher: 'perform_job')
            else
              MSG
            end
          end
        end
      end
    end
  end
end
