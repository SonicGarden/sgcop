# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class UjsOptions < Base
        MSG = 'Deprecated: Rails UJS Attributes.'

        def_node_matcher :link_to_ujs_options?, <<~PATTERN
          (send nil? #link_to_matcher? ... (hash <(pair (sym #deprecated_args?) _) ...>))
        PATTERN

        def on_send(node)
          # TODO: 本来は引数の箇所にのみ警告を表示したい
          link_to_ujs_options?(node) { add_offense(node) }
        end

        private

        def link_to_matcher?(method_name)
          method_name == :link_to
        end

        def deprecated_args?(args)
          %i[method remote].include?(args)
        end
      end
    end
  end
end
