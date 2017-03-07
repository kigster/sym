require 'logger'
module Sym
  module Constants
    module Bash
      Config = {}

      BASH_FILES = Dir.glob("#{File.expand_path('../../../bin', __FILE__)}/sym.*").freeze
      BASH_FILES.each do |bash_file|
        source_file = File.basename(bash_file)
        home_file   = "#{ENV['HOME']}/.#{source_file}"

        Config[source_file.gsub(/sym\./, '').to_sym] = {
          dest: home_file,
          source: bash_file,
          script: "[[ -f #{home_file} ]] && source #{home_file}"
        }
      end
    end

    module Log
      NIL = Logger.new(nil).freeze # empty logger
      LOG = Logger.new(STDERR).freeze
    end

    ENV_ARGS_VARIABLE_NAME = 'SYM_ARGS'.freeze
    SYM_KEY_FILE           = "#{ENV['HOME']}/.sym.key"
  end
end
