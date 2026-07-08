# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # ループ内で1件ずつperform_laterを呼ぶことを検出し、perform_all_laterでのまとめてenqueueを促す。
      class NoLoopedPerformLater < Base
        MSG = 'Avoid calling `perform_later` one-by-one inside a loop. Use `perform_all_later` to enqueue jobs in bulk.'

        def_node_matcher :each_like_block?, <<~PATTERN
          (block
            (send _ {:each :map :each_with_index :each_with_object :flat_map :collect} ...)
            ...
            $_)
        PATTERN

        def_node_matcher :perform_later_call?, <<~PATTERN
          (send const_type? :perform_later ...)
        PATTERN

        def on_block(node)
          body = each_like_block?(node)
          return unless body

          each_direct_child(body) do |child|
            add_offense(child) if perform_later_call?(child)
          end
        end

        private

        def each_direct_child(body, &)
          if body.begin_type?
            body.children.each(&)
          else
            yield(body)
          end
        end
      end
    end
  end
end
