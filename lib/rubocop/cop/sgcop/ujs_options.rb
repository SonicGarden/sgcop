# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class UjsOptions < Base
        MSG = 'Deprecated: Rails UJS Attributes.'

        def_node_matcher :link_to_ujs_options?, <<~PATTERN
          (send nil? #link_to_matcher? ... (hash <(pair (sym #deprecated_link_args?) _) ...>))
        PATTERN

        def_node_matcher :form_ujs_options?, <<~PATTERN
          (send nil? #form_helper_matcher? ... (hash <(pair (sym #deprecated_form_args?) _) ...>))
        PATTERN

        def on_send(node)
          # TODO: 本来は引数の箇所にのみ警告を表示したい
          link_to_ujs_options?(node) { add_offense(node) }
          form_ujs_options?(node) { add_offense(node) }
        end

        private

        def link_to_matcher?(method_name)
          method_name == :link_to
        end

        def form_helper_matcher?(method_name)
          method_name.to_s.end_with?('_form_with', '_form_for') ||
            %i[form_with form_for].include?(method_name)
        end

        def deprecated_link_args?(args)
          %i[method remote].include?(args)
        end

        def deprecated_form_args?(args)
          %i[remote local].include?(args)
        end
      end
    end
  end
end
