# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class CanCanCanResourceAuthorization < Base
        MSG = 'Missing resource authorization.'.freeze

        def on_class(node)
          return if resource_authorized?(node)

          add_offense(node, severity: :error)
        end

        private

        def resource_authorized?(node)
          node.child_nodes.any? do |child_node|
            authorize_method?(child_node) || resource_authorized?(child_node)
          end
        end

        AUTHORIZE_METHODS = %i[
          authorize!
          authorize_resource
          load_and_authorize_resource
        ].freeze

        def authorize_method?(node)
          node.type == :send &&
            AUTHORIZE_METHODS.include?(node.method_name)
        end
      end
    end
  end
end
