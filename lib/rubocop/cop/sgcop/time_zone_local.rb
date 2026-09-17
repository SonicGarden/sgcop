# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # Time.zone.localの数値羅列ではなく日時文字列の.in_time_zoneを推奨する。
      class TimeZoneLocal < Base
        extend AutoCorrector

        MSG = 'Time.zone.localではなく日時文字列の.in_time_zoneを使用してください。'

        RESTRICT_ON_SEND = %i[local].freeze

        def_node_matcher :time_zone_local, <<~PATTERN
          (send (send (const {nil? cbase} :Time) :zone) :local $int+)
        PATTERN

        def on_send(node)
          args = time_zone_local(node)
          return unless args
          # 日付が揃う3引数から秒までの6引数までを対象とする。
          # 1〜2引数と7引数(usec)は書き換えの読みやすさの効果が薄いため意図的に対象外。
          return unless (3..6).cover?(args.size)

          add_offense(node) do |corrector|
            corrector.replace(node, replacement(args))
          end
        end

        private

        def replacement(args)
          # 時分秒が省略された場合は0で補完する
          year, month, day, hour, min, sec = [*args.map(&:value), 0, 0, 0]

          format(
            "'%<year>04d-%<month>02d-%<day>02d %<hour>02d:%<min>02d:%<sec>02d'.in_time_zone",
            year:,
            month:,
            day:,
            hour:,
            min:,
            sec:
          )
        end
      end
    end
  end
end
