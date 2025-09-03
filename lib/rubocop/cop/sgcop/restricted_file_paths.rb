# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class RestrictedFilePaths < Base
        def on_new_investigation
          return if restricted_patterns.empty?
          return unless target_file?

          file_path = processed_source.file_path
          app_root = find_app_root(file_path)
          return unless app_root

          relative_path = file_path.delete_prefix("#{app_root}/")
          check_patterns(relative_path)
        end

        private

        def target_file?
          processed_source.file_path && !processed_source.file_path.empty?
        end

        def check_patterns(relative_path)
          restricted_patterns.each do |pattern, message|
            next unless File.fnmatch(pattern, relative_path, File::FNM_PATHNAME)

            add_global_offense(message)
            break
          end
        end

        def restricted_patterns
          @restricted_patterns ||= cop_config['RestrictedPatterns'] || {}
        end

        def find_app_root(file_path)
          current_dir = File.dirname(file_path)

          loop do
            return current_dir if File.exist?(File.join(current_dir, 'Gemfile'))

            parent_dir = File.dirname(current_dir)
            break if parent_dir == current_dir

            current_dir = parent_dir
          end

          nil
        end
      end
    end
  end
end
