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

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rubocop', '~> 1.79.0'
  spec.add_dependency 'rubocop-capybara', '~> 2.22.0'
  spec.add_dependency 'rubocop-factory_bot', '~> 2.27.0'
  spec.add_dependency 'rubocop-performance', '~> 1.25.0'
  spec.add_dependency 'rubocop-rails', '~> 2.32.0'
  spec.add_dependency 'rubocop-rake', '~> 0.7.1'
  spec.add_dependency 'rubocop-rspec', '~> 3.6.0'
  spec.add_dependency 'rubocop-rspec_rails', '~> 2.31.0'
end
