require 'logger'
module Sym
  #
  # This module is responsible for installing Sym BASH extensions.
  #
  module Constants

    BASH_FILES = Dir.glob("#{File.expand_path('../../bin', __dir__)}/sym.*.bash").freeze

    class << self
      attr_reader :user_home

      def user_home=(value)
        @user_home = value
        register_bash_files!
      end

      def config
        @config ||= {}
      end

      def sym_key_file
        "#{user_home}/.sym.key"
      end

      def register_bash_files!
        BASH_FILES.each do |bash_file|
          register_bash_extension bash_file
        end
      end

      private

      def register_bash_extension(bash_file)
        return unless user_home && Dir.exist?(user_home)

        source_file = File.basename(bash_file)
        home_file   = "#{user_home}/.#{source_file}"
        config_key  = source_file.gsub(/sym\./, '').gsub(/\.bash/, '').to_sym

        config[config_key] = {
          dest:   home_file,
          source: bash_file,
          script: "[[ -f #{home_file} ]] && source #{home_file}"
        }
      end
    end

    self.user_home ||= ::Dir.home rescue nil
    self.user_home ||= '/tmp'

    self.register_bash_files!

    module Log
      NIL = Logger.new(nil).freeze # empty logger
      LOG = Logger.new($stderr).freeze
    end
  end
end
