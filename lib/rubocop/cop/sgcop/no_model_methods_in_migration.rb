# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      # マイグレーション内でモデルクラスのメソッドを呼び出すことを検出する。
      # モデルは時間と共に変わる「ただの Ruby クラス」なので、過去のマイグレーションが
      # モデルに依存すると、後から DB を新規構築する際にエラーになる。
      #
      # 定数レシーバへのメソッド呼び出しを検出するが、以下は除外する:
      # - ActiveRecord / ActiveStorage のフレームワーク定数（ActiveRecord::Migration[x.y] 宣言など）
      # - そのファイル内で定数代入された定数（配列/ハッシュ定数や一時クラス TempUser = Class.new(...) など）
      # - AllowedConstants で許可された定数
      class NoModelMethodsInMigration < Base
        MSG = 'Do not call model methods in migrations. Models change over time; use raw SQL or a rake task instead.'

        # レシーバ先頭がこれらの定数（の名前空間）なら除外する。
        # - ActiveRecord: ActiveRecord::Migration[x.y] 継承宣言や ActiveRecord::Base.connection など、
        #   全マイグレーションの根幹となるため無視必須。
        # - ActiveStorage: Rails 標準の active_storage マイグレーション（ActiveStorage::Blob など）で使われる。
        # その他の Rails 定数・Ruby 組み込みクラス（Time, Date など）はデフォルトでは無視せず、
        # 必要なプロジェクトは AllowedConstants で許可する。
        IGNORED_CONSTANTS = %w[
          ActiveRecord
          ActiveStorage
        ].freeze

        def on_new_investigation
          ast = processed_source.ast
          return unless ast

          @local_constants = collect_local_constants(ast)

          ast.each_node(:send) do |node|
            check_send(node)
          end
        end

        private

        # ファイル内で定数代入 (casgn) された定数名を集める。
        def collect_local_constants(ast)
          ast.each_node(:casgn).to_set { |casgn| casgn.children[1].to_s }
        end

        def check_send(node)
          # チェーンの内側 send（例: Post.where(...) の where）は最外 send から辿るので
          # 二重に offense を出さないよう、レシーバ位置にある send はスキップする。
          return if chained_receiver?(node)

          base = const_receiver(node)
          return unless base

          const_name = base.const_name
          return if ignored_constant?(const_name)
          return if local_constant?(const_name)
          return if allowed_constant?(const_name)

          add_offense(node)
        end

        def chained_receiver?(node)
          node.parent&.send_type? && node.parent.receiver == node
        end

        # チェーンを辿って先頭の const ノードを返す（無ければ nil）。
        def const_receiver(node)
          receiver = node.receiver
          receiver = receiver.receiver while receiver&.send_type?
          receiver if receiver&.const_type?
        end

        def ignored_constant?(const_name)
          IGNORED_CONSTANTS.include?(const_name.split('::').first)
        end

        def local_constant?(const_name)
          segments = const_name.split('::')
          @local_constants.include?(segments.first) || @local_constants.include?(segments.last)
        end

        def allowed_constant?(const_name)
          allowed_constants.include?(const_name)
        end

        def allowed_constants
          Array(cop_config['AllowedConstants'])
        end
      end
    end
  end
end
