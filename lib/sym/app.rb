require 'sym'
require 'active_support/inflector'
require 'colored2'
module Sym

  # The {Sym::App} Module is responsible for handing user input and executing commands.
  # Central class in this module is the {Sym::App::CLI} class. However, it is
  # recommended that ruby integration with the {Sym::App} module functionality
  # is done via the {Sym::Application} class.
  #
  # Methods in this module are responsible for reporting errors and
  # maintaining the future exit code class-global variable.
  #
  # It also contains several helpers that enable some additional functionality
  # on Mac OS-X (such as using KeyChain for storing encryption keys).
  #
  module App
    class << self
      attr_accessor :exit_code
    end

    self.exit_code = 0

    def self.out
      STDERR
    end

    def self.log(level, *args, **opts)
      Sym::Constants::Log::LOG.send(level, *args) if opts[:debug]
    end

    def self.error(config: {},
      exception: nil,
      type: nil,
      details: nil,
      reason: nil,
      comments: nil,
      command: nil)

      lines = []

      error_type    = "#{(type || exception.class.name)}"
      error_details = (details || exception.message)

      if exception && (config && config[:trace] || reason == 'Unknown Error')
        lines << "#{error_type.red.underlined}: #{error_details.white.on.red}\n"
        lines << exception.backtrace.join("\n").red.bold if config[:trace]
        lines << "\n"
      end

      operation = command ? "to #{command.class.short_name.to_s.humanize.downcase}" : ''
      reason    = exception.message if reason.nil? && exception

      lines << " error #{operation} → ".white.on.red+ " #{reason}".bold.red if reason
      lines << "#{comments}" if comments

      error_report = lines.compact.join("\n") || 'Undefined error'

      self.out.puts(error_report) if error_report.present?
      self.exit_code = 1
    end

    def self.is_osx?
      Gem::Platform.local.os.eql?('darwin')
    end

    def self.this_os
      Gem::Platform.local.os
    end
  end
end

require 'sym/app/short_name'
require 'sym/app/args'
require 'sym/app/cli'
require 'sym/app/commands'
require 'sym/app/keychain'
require 'sym/app/output'
