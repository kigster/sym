# frozen_string_literal: true

require 'logger'
module Sym
  module Constants
    ENV_ARGS_VARIABLE_NAME = 'SYM_ARGS'
    SYM_KEY_FILE           = (ENV['SYM_KEY_FILE'] || "#{Dir.home}/.sym.key").freeze
    DEFAULT_CACHE_TTL      = 300

    module Bash
      BASH_FILES = Dir.glob("#{File.expand_path('../../bin', __dir__)}/sym.*.bash")

      Config = {}

      class << self
        def register_bash_files!
          BASH_FILES.each do |bash_file|
            register_bash_extension bash_file, Config
          end
        end

        private

        def register_bash_extension(bash_file, hash)
          source_file = File.basename(bash_file)
          home_file   = "#{Dir.home}/.#{source_file}"

          hash[source_file.gsub(/sym\./, '').gsub(/\.bash/, '').to_sym] = {
            dest: home_file,
            source: bash_file,
            script: "[[ -f #{home_file} ]] && source #{home_file}"
          }
        end
      end

      register_bash_files!
    end

    module Log
      NIL = Logger.new(nil).freeze # empty logger
      LOG = Logger.new(STDERR).freeze
    end
  end
end
