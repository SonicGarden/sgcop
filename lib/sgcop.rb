require 'rubocop'

require 'sgcop/version'
require 'rubocop/sgcop/inject'

RuboCop::Sgcop::Inject.defaults!

require 'rubocop/cop/sgcop/missing_depenedent'
