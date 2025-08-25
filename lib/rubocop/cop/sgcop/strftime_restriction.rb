# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class StrftimeRestriction < Base
        MSG = 'strftimeではなくI18n.lを使用してローカライズしてください。'

        def on_send(node)
          return unless node.method_name == :strftime
          return unless date_time_object?(node.receiver)

          add_offense(node.loc.expression, message: MSG)
        end

        private

        def date_time_object?(node)
          return false unless node

          case node.type
          when :lvar, :ivar, :cvar, :gvar
            # 変数の場合は警告する（安全側に倒す）
            true
          when :send
            # メソッド呼び出しの場合
            date_time_method?(node)
          when :const
            # 定数の場合（Date, Time, DateTime等）
            date_time_class?(node)
          else
            false
          end
        end

        def date_time_method?(node)
          return false unless node.type == :send

          method_name = node.method_name
          receiver = node.receiver

          return true if known_date_time_method?(method_name)

          # レシーバーがDate/Time系クラスの場合
          date_time_receiver?(receiver)
        end

        def known_date_time_method?(method_name)
          date_time_methods = %i[
            today yesterday tomorrow
            now current zone parse at new
            beginning_of_day end_of_day
            beginning_of_month end_of_month
            beginning_of_year end_of_year
            ago since from_now
            days day weeks week months month years year
            hour hours minute minutes second seconds
            to_date to_time to_datetime
          ]

          date_time_methods.include?(method_name)
        end

        def date_time_receiver?(receiver)
          return false unless receiver

          case receiver.type
          when :const
            date_time_class?(receiver)
          when :send
            # チェーンされた呼び出し (例: Time.zone.now, Date.today.beginning_of_month)
            date_time_method?(receiver)
          else
            false
          end
        end

        def date_time_class?(node)
          return false unless node.type == :const

          # Date, Time, DateTime等を検出
          if node.children[0].nil?
            %w[Date Time DateTime].include?(node.children[1].to_s)
          elsif node.children[0].type == :const && node.children[0].children[1] == :ActiveSupport
            node.children[1] == :TimeWithZone
          else
            false
          end
        end
      end
    end
  end
end
