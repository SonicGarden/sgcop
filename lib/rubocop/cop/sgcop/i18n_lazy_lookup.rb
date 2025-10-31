# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # rubocop:disable Metrics/ClassLength
      #
      # Checks for places where I18n explicit keys should be used instead of lazy lookup.
      #
      # This cop enforces explicit key usage in controllers, components and views.
      #
      # @example EnforcedStyle: explicit (default)
      #   # en.yml
      #   # en:
      #   #   book_component:
      #   #     title: Book Title
      #
      #   # bad - in app/components/book_component.rb
      #   class BookComponent < ViewComponent::Base
      #     def title
      #       t('.title')
      #     end
      #   end
      #
      #   # good
      #   class BookComponent < ViewComponent::Base
      #     def title
      #       t('book_component.title')
      #     end
      #   end
      #
      #   # bad - in app/views/books/index.html.erb (checked via erblint)
      #   <%= t('.title') %>
      #
      #   # good
      #   <%= t('books.index.title') %>
      #
      class I18nLazyLookup < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        MSG = 'Use %<style>s key for better maintainability.'

        RESTRICT_ON_SEND = %i[translate t].freeze

        def_node_matcher :translate_call?, <<~PATTERN
          (send nil? {:translate :t} ${sym_type? str_type?} ...)
        PATTERN

        def on_send(node)
          translate_call?(node) do |key_node|
            enforced_style = cop_config['EnforcedStyle']&.to_sym || :explicit
            case enforced_style
            when :lazy
              handle_lazy_style(node, key_node)
            when :explicit
              handle_explicit_style(node, key_node)
            end
          end
        end

        private

        def handle_lazy_style(node, key_node)
          key = key_node.value
          return if key.to_s.start_with?('.')

          context = detect_context(node)
          return unless context

          scoped_key = get_scoped_key(key_node, context)
          return unless key == scoped_key

          add_offense(key_node, message: format(MSG, style: 'lazy lookup')) do |corrector|
            unscoped_key = key_node.value.to_s.split('.').last
            corrector.replace(key_node, "'.#{unscoped_key}'")
          end
        end

        def handle_explicit_style(node, key_node)
          key = key_node.value
          return unless key.to_s.start_with?('.')

          context = detect_context(node)
          return unless context

          scoped_key = get_scoped_key(key_node, context)
          add_offense(key_node, message: format(MSG, style: 'explicit')) do |corrector|
            corrector.replace(key_node, "'#{scoped_key}'")
          end
        end

        def detect_context(node)
          processed_source = node.source_range.source_buffer
          file_path = processed_source.name

          # Check for views
          if file_path.include?('app/views/')
            return detect_view_context(node, file_path)
          end

          # Check for components
          if file_path.include?('app/components/')
            return detect_component_context(node)
          end

          # Check for controllers
          detect_controller_context(node)
        end

        def detect_controller_context(node)
          action_node = node.each_ancestor(:def).first
          return unless action_node

          controller_node = node.each_ancestor(:class).first
          return unless controller_node && controller_node.identifier.source.end_with?('Controller')

          { type: :controller, class_node: controller_node, method_node: action_node }
        end

        def detect_view_context(_node, file_path)
          # Extract view path like "books/index" from "app/views/books/index.html.erb"
          match = file_path.match(%r{app/views/(.+?)(?:\.[^/]+)*$})
          return unless match

          view_path = match[1]

          { type: :view, view_path: view_path }
        end

        def detect_component_context(node)
          # Find the class definition
          class_node = node.each_ancestor(:class).first
          return unless class_node

          # Find the method definition
          method_node = node.each_ancestor(:def).first
          return unless method_node

          { type: :component, class_node: class_node, method_node: method_node }
        end

        def get_scoped_key(key_node, context)
          key = key_node.value.to_s.split('.').last

          case context[:type]
          when :controller
            path = controller_path(context[:class_node])
            action_name = context[:method_node].method_name
            "#{path}.#{action_name}.#{key}"
          when :view
            view_path = context[:view_path]
            dir = File.dirname(view_path)
            file = File.basename(view_path)
            "#{dir.tr('/', '.')}.#{file}.#{key}"
          when :component
            path = component_path(context[:class_node])
            "#{path}.#{key}"
          end
        end

        def controller_path(controller_node)
          controller_name = controller_node.identifier.source
          module_name = controller_node.parent_module_name

          path = if module_name == 'Object'
                   controller_name
                 else
                   "#{module_name}::#{controller_name}"
                 end
          path.delete_suffix('Controller').underscore
        end

        def component_path(class_node)
          component_name = class_node.identifier.source
          component_name
            .delete_suffix('Component')
            .gsub('::', '/')
            .underscore
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
