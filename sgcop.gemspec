lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sgcop/version'

Gem::Specification.new do |spec|
  spec.name          = 'sgcop'
  spec.version       = Sgcop::VERSION
  spec.authors       = ['maedana']
  spec.email         = ['maedana@sonicgarden.jp']

  spec.summary       = 'SonicGarden標準コーディングスタイル'
  spec.description   = '各プロジェクトのrubocopのデフォルト設定とすることを目的としている'
  spec.homepage      = 'https://github.com/SonicGarden/sgcop'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0.2'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_dependency 'brakeman'
  spec.add_dependency 'brakeman_translate_checkstyle_format'
  spec.add_dependency 'haml_lint', '~> 0.32.0'
  spec.add_dependency 'rubocop', '~> 0.74.0'
  spec.add_dependency 'rubocop-performance', '~> 1.4.1'
  spec.add_dependency 'rubocop-rails', '~> 2.3.0'
  spec.add_dependency 'rubocop-rspec', '~> 1.35.0'
end
