# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class DuplicateIndexInSchema < Base
        MSG = 'インデックス`%<redundant_name>s`は`%<covering_name>s`に含まれているため不要です'

        def on_block(node)
          return unless create_table_block?(node)

          table_name = extract_table_name(node)
          return unless table_name

          indexes = extract_indexes(node)
          check_duplicate_indexes(indexes)
        end

        private

        def create_table_block?(node)
          node.send_node&.method_name == :create_table
        end

        def extract_table_name(node)
          node.send_node.first_argument&.value
        end

        def extract_indexes(block_node)
          indexes = []

          block_node.body&.each_node(:send) do |send_node|
            next unless index_definition?(send_node)

            index_info = build_index_info(send_node)
            indexes << index_info if index_info
          end

          indexes
        end

        def index_definition?(node)
          node.receiver&.lvar_type? &&
            node.receiver.source == 't' &&
            node.method_name == :index
        end

        def build_index_info(node)
          columns = extract_index_columns(node)
          name = extract_index_name(node)

          return unless columns && name

          { columns: columns, name: name, node: node }
        end

        def extract_index_columns(node)
          first_arg = node.first_argument
          return unless first_arg

          case first_arg.type
          when :array
            first_arg.each_value.map { |v| v.value.to_s if v.respond_to?(:value) }.compact
          when :str, :sym
            [first_arg.value.to_s]
          end
        end

        def extract_index_name(node)
          return unless node.arguments.size >= 2

          options = node.arguments[1]
          return unless options&.hash_type?

          find_name_option(options)
        end

        def find_name_option(hash_node)
          hash_node.each_pair do |key, value|
            next unless key.sym_type? && key.value == :name
            return value.value.to_s if value.respond_to?(:value)
          end
          nil
        end

        def check_duplicate_indexes(indexes)
          indexes.each_with_index do |index1, i|
            indexes.each_with_index do |index2, j|
              next if i == j

              next unless index_covered_by?(index1[:columns], index2[:columns])

              add_offense(
                index1[:node],
                message: format(
                  MSG,
                  redundant_name: index1[:name],
                  covering_name: index2[:name]
                )
              )
            end
          end
        end

        def index_covered_by?(columns1, columns2)
          return false if columns1.empty? || columns2.empty?
          return false if columns1.size >= columns2.size

          columns1 == columns2[0...columns1.size]
        end
      end
    end
  end
end
