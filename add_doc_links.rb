# yaml の各ルールにドキュメントのリンクを付加するスクリプト

require 'fileutils'

TOP_CATEGORY_MAP = {
  'Rails' => 'rails',
  'RSpec' => 'rspec',
  'Performance' => 'performance',
  'Capybara' => 'capybara',
  'FactoryBot' => 'factory_bot'
}
DOC_COMMENT_REGEXP = %r{\A# https://docs\.rubocop\.org/}

def add_doc_link_comments(filename)
  tmp_filename = filename + ".tmp"
  File.open(tmp_filename, 'w') do |io|
    IO.foreach(filename) do |line|
      if DOC_COMMENT_REGEXP.match?(line)
        next
      elsif (m = %r{^(.+/.+):}.match(line))
        words = m[1].split('/')
        top_category = words[0]
        category = words[0..-2].join('_').downcase
        name = words.join('').downcase
        top_category_path_name = TOP_CATEGORY_MAP[top_category]
        comment =
          if top_category_path_name
            "# https://docs.rubocop.org/rubocop-#{top_category_path_name}/cops_#{category}.html##{name}"
          else
            "# https://docs.rubocop.org/rubocop/cops_#{category}.html##{name}"
          end
        io.puts(comment)
      end
      io.write(line)
    end
  end
  FileUtils.mv(tmp_filename, filename)
end

FILES = %w[
  ruby/rubocop.yml
  rails/rubocop.yml
]

FILES.each do |filename|
  add_doc_link_comments(filename)
end
