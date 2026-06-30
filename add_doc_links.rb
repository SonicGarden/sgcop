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

def add_doc_link_comments(filename)
  tmp_filename = "#{filename}.tmp"
  File.open(tmp_filename, 'w') do |io|
    File.foreach(filename) do |line|
      if DOC_COMMENT_REGEXP.match?(line)
        next

      elsif (m = %r{^(.+/.+):}.match(line))
        io.puts(doc_url(m[1]))
      end

      io.write(line)
    end
  end
  FileUtils.mv(tmp_filename, filename)
end

FILES = %w[
  ruby/rubocop.yml
  rails/rubocop.yml
  ruby/rubocop_strict.yml
  rails/rubocop_strict.yml
].freeze

FILES.each do |filename|
  add_doc_link_comments(filename)
end
