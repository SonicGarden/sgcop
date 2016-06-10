$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sgcop'

rubocop_path = Gem::Specification.find_by_name('rubocop').gem_dir
Dir["#{rubocop_path}/spec/support/**/*.rb"].each { |f| require f }
