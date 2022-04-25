# yaml の各ルールにドキュメントのリンクを付加するスクリプト

require 'fileutils'

def add_doc_link_comments(filename)
  prev_line = nil
  tmp_filename = filename + ".tmp"
  File.open(tmp_filename, 'w') do |io|
    IO.foreach(filename) do |line|
      if (m = %r{^(.+/.+):}.match(line))
        words = m[1].split('/')
        top_category = words[0].downcase
        category = words[0..-2].join('_').downcase
        name = words.join('').downcase
        comment =
          case top_category
          when 'rails', 'rspec', 'performance'
            "# https://docs.rubocop.org/rubocop-#{top_category}/cops_#{category}.html##{name}"
          else
            "# https://docs.rubocop.org/rubocop/cops_#{category}.html##{name}"
          end
        if prev_line.nil? || prev_line.chomp != comment
          io.puts(comment)
        end
      end
      io.write(line)
      prev_line = line
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
