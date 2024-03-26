require 'rubocop'
require 'sgcop/version'
require 'sgcop/inject'

Sgcop::Inject.defaults!

require 'rubocop/cop/sgcop/simple_format'
require 'rubocop/cop/sgcop/request_remote_ip'
require 'rubocop/cop/sgcop/simple_form_association'
require 'rubocop/cop/sgcop/unscoped'
require 'rubocop/cop/sgcop/whenever'
require 'rubocop/cop/sgcop/ujs_options'
require 'rubocop/cop/sgcop/active_job_queue_adapter'
require 'rubocop/cop/sgcop/on_load_arguments'
require 'rubocop/cop/sgcop/capybara/sleep'
require 'rubocop/cop/sgcop/capybara/matchers'
