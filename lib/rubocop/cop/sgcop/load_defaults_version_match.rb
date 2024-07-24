# frozen_string_literal: true

module RuboCop
  module Cop
    module Sgcop
      class LoadDefaultsVersionMatch < Base
        MSG = 'The load_defaults version (%<version>s) does not match the Rails version (%<gemfile_version>s) specified in the Gemfile.'

        def_node_matcher :load_defaults_version, <<-PATTERN
          (send (send nil? :config) :load_defaults (float $_))
        PATTERN

        def on_send(node)
          load_defaults_version(node) do |version|
            gemfile_version = extract_rails_version
            if gemfile_version && gemfile_version != Gem::Version.new(version)
              add_offense(node, message: format(MSG, version: version, gemfile_version: gemfile_version))
            end
          end
        end

        private

        def extract_rails_version
          # TODO: rubocopで提供されているAPIを使ってもうちょっとスマートに書けそうな気がする
          gemfile_lock_path = File.join(Dir.pwd, 'Gemfile.lock')
          return nil unless File.exist?(gemfile_lock_path)

          gemfile_lock_content = File.read(gemfile_lock_path)
          match = gemfile_lock_content.match(/^\s*rails \((\d+\.\d+)[\d.]+\)/)
          return nil unless match

          Gem::Version.new(match[1])
        end
      end
    end
  end
end
