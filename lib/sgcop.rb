require 'rubocop'
require 'sgcop/version'
require 'sgcop/inject'

Sgcop::Inject.defaults!

require 'rubocop/cop/sgcop/simple_format'
require 'rubocop/cop/sgcop/sleep'
