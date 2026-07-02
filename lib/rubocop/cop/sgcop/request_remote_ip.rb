# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # request.remote_ipの適切な使用を確認する。
      class RequestRemoteIp < Base
        MSG = 'Use `request.remote_ip` instead of ' \
              '`request.remote_addr`.'

        def_node_matcher :remote_addr?, <<~PATTERN
          (send (send nil? :request) {:remote_addr})
        PATTERN

        def on_send(node)
          remote_addr?(node) do
            add_offense(node)
          end
        end
      end
    end
  end
end
