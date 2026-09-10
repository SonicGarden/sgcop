# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # create_tableブロック直後に並ぶadd_indexをブロック内のt.indexに寄せる。
      class IndexInCreateTable < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Define the index inside the `create_table` block with `t.index` instead of a following `add_index`.'

        # ブロック引数名が必要なため、numblock(_1) / itblock(it) は対象外とする。
        def_node_matcher :create_table_block, <<~PATTERN
          (block (send nil? :create_table ${sym str} ...) (args (arg $_)) $_)
        PATTERN

        def_node_matcher :add_index_call, <<~PATTERN
          (send nil? :add_index ${sym str} _ ...)
        PATTERN

        # t.index に移すと意味が変わるオプション。
        # if_not_exists は create_table 側が `**index_options, if_not_exists: td.if_not_exists`
        # の順で渡すため個別指定が握り潰される。algorithm は MySQL のように
        # CREATE TABLE へインライン化されるアダプタでは ALTER 前提の指定が効かなくなる。
        UNSAFE_OPTIONS = %i[if_not_exists algorithm].freeze

        def on_block(node)
          table_name, block_arg, body = create_table_block(node)
          return unless table_name
          # 文の並び以外（if/else の各分岐など）では右兄弟が「直後の行」ではないため、
          # 移動すると制御フローが変わってしまう。begin 直下のみを対象とする。
          return unless node.parent&.begin_type?

          add_index_nodes = adjacent_add_indexes(node, table_name)
          return if add_index_nodes.empty?

          anchor = last_body_child(body)
          add_index_nodes.each do |add_index_node|
            register_offense(node, anchor, block_arg, add_index_node)
          end
        end

        private

        # create_tableブロックの右隣から連続して並ぶ、同一テーブルへのadd_indexを集める。
        # 非マッチのノードが1つでも挟まればそこで打ち切る。
        def adjacent_add_indexes(node, table_name)
          name = table_name.value.to_s

          node.right_siblings.take_while { |sibling| same_table_add_index?(sibling, name) }
        end

        # テーブル名はシンボル・文字列のどちらで書かれていても同一とみなす。
        def same_table_add_index?(sibling, name)
          other = add_index_call(sibling)

          !other.nil? && other.value.to_s == name && !unsafe_options?(sibling)
        end

        # UNSAFE_OPTIONS を含む add_index は t.index と等価にならないため対象外とする。
        # オプションの中身を静的に読めない場合（`**opts` や変数渡し）は、
        # UNSAFE_OPTIONS が隠れている可能性があるため保守的に対象外とする。
        def unsafe_options?(add_index_node)
          options = add_index_node.arguments[2..]
          return false if options.empty?

          options.any? { |option| !inspectable_safe_options?(option) }
        end

        # 中身をすべて読めて、UNSAFE_OPTIONS を含まないハッシュリテラルか。
        def inspectable_safe_options?(option)
          return false unless option.hash_type?
          return false unless option.children.all?(&:pair_type?)

          option.keys.none? { |key| key.sym_type? && UNSAFE_OPTIONS.include?(key.value) }
        end

        # 挿入位置は本体の最終行。本体が空なら do の行に挿入し、
        # インデントは end の桁 + 設定のインデント幅で作る。
        def register_offense(node, anchor, block_arg, add_index_node)
          add_offense(add_index_node) do |corrector|
            # 1行のcreate_tableブロックへ改行を挿入すると壊れるため補正しない。
            next if node.single_line?
            # 引き継げない位置のコメントを削除で失うことになるため補正しない。
            next if dropped_comment?(add_index_node)

            target = anchor ? anchor.source_range : node.loc.begin
            column = anchor ? anchor.loc.column : node.loc.end.column + configured_indentation_width
            new_line = "\n#{' ' * column}#{index_source(block_arg, add_index_node)}"

            corrector.insert_after(range_by_whole_lines(target), new_line)
            corrector.remove(range_by_whole_lines(add_index_node.source_range, include_final_newline: true))
          end
        end

        # ブロック本体の最終ノード（bodyがbeginなら最後の子、空ならnil）。
        def last_body_child(body)
          return nil unless body

          body.begin_type? ? body.children.last : body
        end

        # Layout/IndentationWidth の設定に従う（RuboCop::Cop::Alignment と同じ算出）。
        def configured_indentation_width
          config.for_cop('Layout/IndentationWidth').fetch('Width', 2)
        end

        # add_indexの第2引数以降をソースのまま引き継ぎ、オプションを完全に保持する。
        # add_index行は丸ごと削除するため、行末コメントもここで引き継ぐ。
        def index_source(block_arg, add_index_node)
          args = add_index_node.arguments
          range = args[1].source_range.join(args.last.source_range)
          comment = trailing_comment(add_index_node)

          "#{block_arg}.index #{range.source}#{comment}"
        end

        # add_indexの最終行にある行末コメント（無ければ空文字）。
        def trailing_comment(add_index_node)
          comment = comment_on_line(add_index_node.source_range.last_line)

          comment ? " #{comment.text}" : ''
        end

        # 最終行以外の行にコメントがあるか。引き継ぎ先が定まらないため補正を諦める。
        def dropped_comment?(add_index_node)
          range = add_index_node.source_range

          (range.first_line...range.last_line).any? { |line| comment_on_line(line) }
        end

        def comment_on_line(line)
          processed_source.comments.find { |comment| comment.loc.line == line }
        end
      end
    end
  end
end
