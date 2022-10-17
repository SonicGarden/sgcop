$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sgcop'
require 'debug'

require 'rubocop/rspec/support'

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense
end
