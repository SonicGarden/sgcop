# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class ActiveJobQueueAdapter < Base
        MSG = 'Do not set config.active_job.queue_adapter in config/initializers.'

        def_node_matcher :active_job_adapter_set?, <<~PATTERN
          (send (send (lvar :config) :active_job) :queue_adapter= ...)
        PATTERN

        def on_send(node)
          return unless in_initializers_directory?
          return unless active_job_adapter_set?(node)

          add_offense(node)
        end

        private

        def in_initializers_directory?
          processed_source.file_path.include?('config/initializers/')
        end
      end
    end
  end
end
