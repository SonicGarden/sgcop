require 'rubocop'

require 'sgcop/version'
require 'rubocop/sgcop/inject'

RuboCop::Sgcop::Inject.defaults!

require 'rubocop/cop/rails/missing_depenedent'
