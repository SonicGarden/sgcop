# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class PreferAbsolutePathPartial < Base
        extend AutoCorrector

        MSG = 'パーシャルは絶対パスで指定してください。'

        def_node_matcher :render_with_string?, <<~PATTERN
          (send nil? :render $str ...)
        PATTERN

        def_node_matcher :render_with_partial_option?, <<~PATTERN
          (send nil? :render (hash <(pair (sym :partial) $str) ...>))
        PATTERN

        def_node_matcher :render_with_collection?, <<~PATTERN
          (send nil? :render (hash <(pair (sym :collection) _) (pair (sym :partial) $str) ...>))
        PATTERN

        def on_send(node)
          check_render(node)
        end

        private

        def check_render(node)
          render_with_string?(node) do |path_node|
            check_path(node, path_node)
          end

          render_with_partial_option?(node) do |path_node|
            check_path(node, path_node)
          end

          render_with_collection?(node) do |path_node|
            check_path(node, path_node)
          end
        end

        def check_path(node, path_node)
          path = path_node.value
          return if absolute_path?(path)

          add_offense(path_node) do |corrector|
            absolute_path = calculate_absolute_path(node, path)
            corrector.replace(path_node, %("#{absolute_path}"))
          end
        end

        def absolute_path?(path)
          path.include?('/')
        end

        def calculate_absolute_path(node, relative_path)
          file_path = processed_source.file_path
          return relative_path unless file_path

          # app/views/users/show.html.erb -> users
          match = file_path.match(%r{app/views/(.+?)/[^/]+\.\w+})
          return relative_path unless match

          directory = match[1]
          "#{directory}/#{relative_path}"
        end
      end
    end
  end
end
