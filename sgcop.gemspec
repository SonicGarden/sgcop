# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sgcop/version'

Gem::Specification.new do |spec|
  spec.name          = "sgcop"
  spec.version       = Sgcop::VERSION
  spec.authors       = ["maedana"]
  spec.email         = ["maedana@sonicgarden.jp"]

  spec.summary       = %q{SonicGarden標準コーディングスタイル}
  spec.description   = %q{各プロジェクトのrubocopのデフォルト設定とすることを目的としている}
  spec.homepage      = "https://github.com/SonicGarden/sgcop"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", '~> 3.4'
  spec.add_dependency 'rubocop', '~> 0.49.1'
  spec.add_dependency 'rubocop-rspec', '~> 1.15.1'
  spec.add_dependency 'rubocop-select'
  spec.add_dependency 'rubocop-checkstyle_formatter'
  spec.add_dependency 'checkstyle_filter-git'
  spec.add_dependency 'saddler'
  spec.add_dependency 'saddler-reporter-github'
end
