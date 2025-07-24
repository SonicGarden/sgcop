# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class ResourcesWithoutOnly < Base
        extend AutoCorrector
        MSG = 'Use `only:` option in resource/resources routing.'

        def on_send(node)
          return unless resources_method?(node)
          return if has_only_option?(node)

          add_offense(node) do |corrector|
            autocorrect(corrector, node)
          end
        end

        private

        def resources_method?(node)
          node.method?(:resource) || node.method?(:resources)
        end

        def has_only_option?(node)
          node.each_child_node(:hash) do |hash_node|
            hash_node.each_pair do |key_node, _value_node|
              next unless key_node.sym_type?

              return true if key_node.value == :only
            end
          end

          false
        end

        def autocorrect(corrector, node) # rubocop:disable Metrics/PerceivedComplexity
          method_name = node.method_name
          default_actions = default_actions_for(method_name)

          except_values = extract_except_values(node)
          only_actions = if except_values
                           default_actions - except_values
                         else
                           default_actions
                         end

          if node.arguments.any?(&:hash_type?)
            # 既存のハッシュオプションがある場合
            hash_node = node.arguments.find(&:hash_type?)

            if except_values
              # except:を削除してonly:に置き換える
              replace_except_with_only(corrector, hash_node, only_actions)
            else
              # only:を追加
              corrector.insert_after(hash_node.source_range.end.adjust(begin_pos: -1), ", only: #{format_actions(only_actions)}")
            end
          else
            # オプションがない場合
            corrector.insert_after(node.first_argument.source_range, ", only: #{format_actions(only_actions)}")
          end
        end

        def extract_except_values(node)
          node.each_child_node(:hash) do |hash_node|
            hash_node.each_pair do |key_node, value_node|
              next unless key_node.sym_type? && key_node.value == :except

              return extract_action_symbols(value_node)
            end
          end
          nil
        end

        def extract_action_symbols(value_node)
          case value_node.type
          when :sym
            [value_node.value]
          when :array
            value_node.children.map do |child|
              child.value if child.sym_type?
            end.compact
          else
            []
          end
        end

        def replace_except_with_only(corrector, hash_node, only_actions)
          hash_node.each_pair do |key_node, value_node|
            next unless key_node.sym_type? && key_node.value == :except

            # except: [...] の範囲全体を取得
            range = key_node.source_range.join(value_node.source_range)

            # 後ろにカンマがある場合は、後ろのカンマとスペースを含めて置き換え
            if !preceded_by_comma?(hash_node, key_node) && followed_by_comma?(hash_node, value_node)
              range = range.adjust(end_pos: 2) # ", "を含める
            end

            corrector.replace(range, "only: #{format_actions(only_actions)}")
          end
        end

        def preceded_by_comma?(hash_node, key_node)
          # ハッシュ内でこのキーの前に他のキーがあるかチェック
          pairs = hash_node.pairs
          index = pairs.find_index { |pair| pair.key == key_node }
          index&.positive?
        end

        def followed_by_comma?(hash_node, value_node)
          # ハッシュ内でこの値の後に他のキーがあるかチェック
          pairs = hash_node.pairs
          index = pairs.find_index { |pair| pair.value == value_node }
          index && index < pairs.size - 1
        end

        def default_actions_for(method_name)
          case method_name
          when :resources
            %i[index show new edit create update destroy]
          when :resource
            %i[show new edit create update destroy]
          end
        end

        def format_actions(actions)
          "[#{actions.map { |action| ":#{action}" }.join(', ')}]"
        end
      end
    end
  end
end
