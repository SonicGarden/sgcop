# frozen_string_literal: true

# yaml の各ルールにドキュメントのリンクを付加するスクリプト

require 'fileutils'

TOP_CATEGORY_MAP = {
  'Rails' => 'rails',
  'RSpec' => 'rspec',
  'RSpecRails' => 'rspec_rails',
  'Performance' => 'performance',
  'Capybara' => 'capybara',
  'FactoryBot' => 'factory_bot',
}.freeze
DOC_COMMENT_REGEXP = %r{\A# https://docs\.rubocop\.org/}
# Cop 定義行（`Department/CopName:` や `Department/Sub/CopName:`）だけにマッチさせる。
# Cop 名は英数字のみで、行頭（インデントなし）から始まる。以前は `^(.+/.+):` という
# 緩いパターンだったため `# そのため bin/rails app:...` のようなコメント行にも誤爆していた。
COP_NAME_REGEXP = %r{\A([A-Za-z0-9]+(?:/[A-Za-z0-9]+)+):}

def doc_url(cop_name)
  words = cop_name.split('/')
  top_category = words[0]
  category = words[0..-2].join('_').downcase
  name = words.join('').downcase
  top_category_path_name = TOP_CATEGORY_MAP[top_category]
  if top_category_path_name
    "# https://docs.rubocop.org/rubocop-#{top_category_path_name}/latest/cops_#{category}.html##{name}"
  else
    "# https://docs.rubocop.org/rubocop/latest/cops_#{category}.html##{name}"
  end
end

# Sgcop/* はカスタム Cop で docs.rubocop.org に掲載されないため、自動リンク生成の
# 対象外とする（GitHub リンクは yml 側に手書きで付与済み）。コメントアウトされた
# `# Sgcop/...` 行も除外できるよう、先頭の `# ` を取り除いてから判定する。
def custom_cop?(cop_name)
  cop_name.sub(/\A#\s*/, '').start_with?('Sgcop/')
end

def add_doc_link_comments(filename)
  tmp_filename = "#{filename}.tmp"
  File.open(tmp_filename, 'w') do |io|
    File.foreach(filename) do |line|
      if DOC_COMMENT_REGEXP.match?(line)
        next

      elsif (m = COP_NAME_REGEXP.match(line)) && !custom_cop?(m[1])
        io.puts(doc_url(m[1]))
      end

      io.write(line)
    end
  end
  FileUtils.mv(tmp_filename, filename)
end

FILES = %w[
  ruby/rubocop.yml
  ruby/rubocop_rspec.yml
  rails/rubocop.yml
  ruby/rubocop_strict.yml
  ruby/rubocop_rspec_strict.yml
  rails/rubocop_strict.yml
].freeze

FILES.each do |filename|
  add_doc_link_comments(filename)
end
