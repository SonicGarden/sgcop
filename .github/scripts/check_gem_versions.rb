#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'json'

gemspec_path = File.expand_path('../../sgcop.gemspec', __dir__)
pr_body_path = File.expand_path('../../pr_body.md', __dir__)
content = File.read(gemspec_path)

updates = []

content.gsub!(/spec\.add_dependency '(?<name>[^']+)', '~> (?<version>\d+\.\d+\.\d+)'/) do
  m = Regexp.last_match
  name = m[:name]
  current = Gem::Version.new(m[:version])

  uri = URI("https://rubygems.org/api/v1/gems/#{name}.json")
  data = JSON.parse(Net::HTTP.get(uri))
  latest = Gem::Version.new(data['version'])
  major, minor, = latest.segments
  new_version = "#{major}.#{minor}.0"

  # major/minor が上がったときだけ更新（patch だけの差は ~> 制約内なので追従不要）
  if (latest.segments.first(2) <=> current.segments.first(2)).positive?
    puts "#{name}: #{current} -> #{new_version} (latest: #{latest})"
    changelog_url = data['changelog_uri'] ||
                    data.dig('metadata', 'changelog_uri') ||
                    data['source_code_uri'] ||
                    data['homepage_uri']
    updates << { name: name, old: current.to_s, new: new_version, changelog_url: changelog_url }
    "spec.add_dependency '#{name}', '~> #{new_version}'"
  else
    puts "#{name}: #{current} (up to date, latest: #{latest})"
    m[0]
  end
end

if updates.empty?
  puts "\nAll gems are up to date."
else
  File.write(gemspec_path, content)
  puts "\nsgcop.gemspec updated."

  rows = updates.map do |u|
    changelog = u[:changelog_url] ? "[CHANGELOG](#{u[:changelog_url]})" : '-'
    "| #{u[:name]} | `~> #{u[:old]}` → `~> #{u[:new]}` | #{changelog} |"
  end
  File.write(pr_body_path, <<~BODY)
    RubyGems の最新バージョンに合わせて gemspec の制約を更新しました。

    ## 更新された依存

    | gem | 変更 | CHANGELOG |
    |-----|------|-----------|
    #{rows.join("\n")}
  BODY
  puts 'pr_body.md written.'
end
