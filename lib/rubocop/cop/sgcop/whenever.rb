# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class Whenever < Base
        MSG = 'Use 24-hour clock to avoid errors.'

        def_node_matcher :twelve_hour?, <<~PATTERN
          (send nil? #whenever_matcher? ... (hash <$(pair (sym :at) #warning_args?) ...>))
        PATTERN

        def on_send(node)
          return unless processed_source.lines.map(&:strip).include?('set :chronic_options, hours24: true')

          twelve_hour?(node) { |arg| add_offense(arg) }
        end

        private

        def whenever_matcher?(method_name)
          method_name == :every
        end

        def warning_args?(args)
          return false unless args.respond_to?(:value)

          value = args.value
          value.include?('am') || value.include?('pm')
        end
      end
    end
  end
end
