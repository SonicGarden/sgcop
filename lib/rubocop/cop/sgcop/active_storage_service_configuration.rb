# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class ActiveStorageServiceConfiguration < Base
        MSG_MISSING = 'Set config.active_storage.service for production. Active Storage uses local disk by default.'
        MSG_LOCAL = 'Do not use :local for config.active_storage.service in production.'

        # config.active_storage.service = ... への代入を探す。
        # config レシーバは configure ブロック内の lvar (|config|) と
        # トップレベルの (send nil? :config) の両形態がありうる。
        def_node_search :service_assignment, <<~PATTERN
          (send (send {nil? (lvar :config) (send nil? :config)} :active_storage) :service= $_)
        PATTERN

        def on_new_investigation
          return unless production_environment_file?
          return unless cloud_storage_configured?

          ast = processed_source.ast
          return unless ast

          assignments = service_assignment(ast).to_a
          if assignments.empty?
            add_offense(missing_offense_range(ast), message: MSG_MISSING)
          else
            check_local_service(assignments)
          end
        end

        private

        def check_local_service(assignments)
          assignments.each do |value_node|
            next unless value_node.sym_type? && value_node.value == :local

            add_offense(value_node.parent, message: MSG_LOCAL)
          end
        end

        # 欠如時の offense は Rails.application.configure の呼び出し部分を指す。
        # configure ブロックが無ければ AST 全体にフォールバックする。
        def missing_offense_range(ast)
          configure_node =
            ast.each_node(:block).find do |block|
              block.send_node.method?(:configure)
            end
          (configure_node&.send_node || ast).source_range
        end

        def production_environment_file?
          processed_source.file_path.to_s.include?('config/environments/production.rb')
        end

        def cloud_storage_configured?
          path = File.join(Dir.pwd, 'config', 'storage.yml')
          return false unless File.exist?(path)

          File.read(path).each_line.any? do |line|
            next false if line =~ /\A\s*#/

            m = line.match(/\A\s*service:\s*(\S+)/)
            m && m[1] != 'Disk'
          end
        end
      end
    end
  end
end
