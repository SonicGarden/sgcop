# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Rspec
        class ActiveJobTestHelper < Base
          MSG_HAVE_ENQUEUED_JOB = 'Use `assert_enqueued_jobs(count)` or `assert_enqueued_with` instead of `have_enqueued_job`.'
          MSG_HAVE_BEEN_ENQUEUED = 'Use `assert_enqueued_with` instead of `have_been_enqueued`.'
          MSG_ENQUEUE_JOB = 'Use `assert_enqueued_jobs` with a block instead of `enqueue_job`.'
          MSG_HAVE_PERFORMED_JOB = 'Use `assert_performed_jobs(count)` or `assert_performed_with` instead of `have_performed_job`.'
          MSG_HAVE_BEEN_PERFORMED = 'Use `assert_performed_with` instead of `have_been_performed`.'
          MSG_PERFORM_JOB = 'Use `assert_performed_jobs` with a block instead of `perform_job`.'

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
            in :have_enqueued_job
              MSG_HAVE_ENQUEUED_JOB
            in :have_been_enqueued
              MSG_HAVE_BEEN_ENQUEUED
            in :enqueue_job
              MSG_ENQUEUE_JOB
            in :have_performed_job
              MSG_HAVE_PERFORMED_JOB
            in :have_been_performed
              MSG_HAVE_BEEN_PERFORMED
            in :perform_job
              MSG_PERFORM_JOB
            end
          end
        end
      end
    end
  end
end
