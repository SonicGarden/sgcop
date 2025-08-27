# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      module Capybara
        class FragileSelector < Base
          MSG_CLASS = 'Avoid using CSS class selectors as they are fragile and break when styles change. Use data attributes or accessible attributes instead.'
          MSG_ID = 'Avoid using ID selectors as they are fragile and break when markup changes. Use data attributes or accessible attributes instead.'
          MSG_HREF = 'Avoid using partial href matching as it is fragile. Use data attributes or accessible attributes instead.'
          MSG_WITHIN_CLASS = 'Avoid using CSS class selectors in within blocks. Use data attributes or accessible attributes instead.'
          MSG_XPATH = 'Avoid using XPath selectors as they are fragile and break when markup changes. Use data attributes or accessible attributes instead.'

          CAPYBARA_METHODS = %i[find find_all all first click_on within have_css].freeze

          def on_send(node)
            return unless capybara_method?(node)

            if node.method_name == :within
              check_within_selector(node)
            else
              check_selector(node)
            end
          end

          private

          def capybara_method?(node)
            CAPYBARA_METHODS.include?(node.method_name)
          end

          def check_selector(node)
            # XPathセレクタのチェック
            if xpath_selector?(node)
              add_offense(node.first_argument, message: MSG_XPATH)
              return
            end

            return unless node.first_argument&.str_type?

            selector = node.first_argument.value
            check_fragile_patterns(node.first_argument, selector)
          end

          def check_within_selector(node)
            return unless node.first_argument

            # XPathセレクタのチェック
            if xpath_selector?(node)
              add_offense(node.first_argument, message: MSG_XPATH)
              return
            end

            if node.first_argument.str_type?
              selector = node.first_argument.value
              check_fragile_patterns(node.first_argument, selector, within_context: true)
            end
          end

          def check_fragile_patterns(node, selector, within_context: false)
            return unless selector.is_a?(String)

            if css_class_selector?(selector)
              msg = within_context ? MSG_WITHIN_CLASS : MSG_CLASS
              add_offense(node, message: msg)
            elsif id_selector?(selector)
              add_offense(node, message: MSG_ID)
            elsif partial_href_selector?(selector)
              add_offense(node, message: MSG_HREF)
            end
          end

          def css_class_selector?(selector)
            selector.match?(/^\.[\w-]+/) || selector.match?(/\s+\.[\w-]+/) ||
              selector.match?(/^[\w]+\.[\w\\:_-]+/)
          end

          def id_selector?(selector)
            selector.match?(/^#[\w-]+/) || selector.match?(/\s+#[\w-]+/)
          end

          def partial_href_selector?(selector)
            selector.match?(/\[href\*=/)
          end

          def xpath_selector?(node)
            # find(:xpath, '...') の形式をチェック
            return false unless node.first_argument&.sym_type?

            node.first_argument.value == :xpath
          end
        end
      end
    end
  end
end
