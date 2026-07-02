# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # resourcesルーティングでonlyオプションの使用を推奨する。
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

        def autocorrect(corrector, node)
          hash_node = node.arguments.find(&:hash_type?)
          except_values = hash_node && extract_except_values(hash_node)

          if except_values
            # except:を削除してonly:に置き換える
            only_actions = default_actions_for(node.method_name) - except_values
            replace_except_with_only(corrector, hash_node, only_actions)
          else
            # only:を追加
            add_only_option(corrector, node, hash_node)
          end
        end

        def add_only_option(corrector, node, hash_node)
          only_actions = default_actions_for(node.method_name)
          target = hash_node ? hash_node.source_range.end.adjust(begin_pos: -1) : node.first_argument.source_range

          corrector.insert_after(target, ", only: #{format_actions(only_actions)}")
        end

        def extract_except_values(hash_node)
          hash_node.each_pair do |key_node, value_node|
            next unless key_node.sym_type? && key_node.value == :except

            return extract_action_symbols(value_node)
          end
          nil
        end

        def extract_action_symbols(value_node)
          case value_node.type
          when :sym
            [value_node.value]
          when :array
            value_node.children.map { |child|
              child.value if child.sym_type?
            }.compact
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
