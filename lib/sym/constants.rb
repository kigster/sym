require 'logger'
module Sym
  module Constants
    module Completion
      FILE = '.sym.completion'.freeze
      PATH = "#{ENV['HOME']}/#{FILE}".freeze
      Config = {
        file:   File.expand_path('../../../bin/sym.completion', __FILE__),
        script: "[[ -f '#{PATH}' ]] && source '#{PATH}'",
      }.freeze

    end

    module Log
      NIL = Logger.new(nil).freeze # empty logger
      LOG = Logger.new(STDERR).freeze
    end

    ENV_ARGS_VARIABLE_NAME = 'SYM_ARGS'.freeze
    SYM_KEY_FILE = "#{ENV['HOME']}/.sym.key"
  end
end


