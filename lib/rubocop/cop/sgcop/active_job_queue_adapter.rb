# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class ActiveJobQueueAdapter < Base
        MSG = 'Do not set config.active_job.queue_adapter in config/initializers.'

        def on_send(node)
          return unless in_initializers_directory?
          return unless active_job_adapter_set?(node)

          add_offense(node)
        end

        private

        def in_initializers_directory?
          processed_source.file_path.include?('config/initializers/')
        end

        def active_job_adapter_set?(node)
          return false unless node.send_type?
          return false unless node.method_name == :queue_adapter=
          return false unless node.receiver&.method_name == :active_job
          return false unless node.receiver.receiver&.type == :lvar && node.receiver.receiver&.children&.first == :config

          true
        end
      end
    end
  end
end
