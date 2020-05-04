module Sgcop
  module Inject
    DEFAULT_FILE = File.expand_path('../../config/default.yml', __dir__)

    def self.defaults!
      path = File.absolute_path(DEFAULT_FILE)
      hash = RuboCop::ConfigLoader.send(:load_yaml_configuration, path)
      config = RuboCop::Config.new(hash, path)
      puts "configuration from #{DEFAULT_FILE}" if RuboCop::ConfigLoader.debug?
      config = RuboCop::ConfigLoader.merge_with_default(config, path)
      RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, config)
    end
  end
end
