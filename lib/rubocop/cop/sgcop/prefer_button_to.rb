# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class PreferButtonTo < Base
        MSG = 'Use `button_to` instead of a form with a single button.'

        def_node_matcher :form_with_single_button?, <<~PATTERN
          (block
            (send _ #form_helper_matcher? ...)
            (args (arg _f))
            `(begin
              $(send (lvar _f) {:submit :button} ...)))
        PATTERN

        def_node_matcher :form_with_only_button?, <<~PATTERN
          (block
            (send _ #form_helper_matcher? ...)
            (args (arg _f))
            $(send (lvar _f) {:submit :button} ...))
        PATTERN

        def on_block(node)
          # Check for form with a single button wrapped in begin
          form_with_single_button?(node) do |_button_node|
            add_offense(node.loc.expression)
          end

          # Check for form with only a button (no begin wrapper)
          form_with_only_button?(node) do |_button_node|
            add_offense(node.loc.expression)
          end
        end

        private

        def form_helper_matcher?(method_name)
          method_name.to_s.end_with?('_form_with', '_form_for') ||
            %i[form_with form_for].include?(method_name)
        end
      end
    end
  end
end
