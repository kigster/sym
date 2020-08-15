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
      attr_accessor :stdin, :stdout, :stderr
    end

    self.exit_code = 0

    self.stdin     = STDIN
    self.stdout    = STDOUT
    self.stderr    = STDERR

    def self.out
      self.stderr
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

      operation = command ? "to #{command.class.short_name.to_s.humanize.downcase}" : ''
      reason    = exception.message if exception

      if exception && (config && config[:trace] || reason == 'Unknown Error')
        lines << "#{error_type.bold.red}:\n#{error_details.red.italic}\n" + ''.normal
        lines << exception.backtrace.join("\n").red.bold if config[:trace]
        lines << "\n"
      else
        lines << " ✖ Sym Error #{operation}:".bold.red + (reason ? " #{reason} ".red.italic: " #{error_details}")[0..70] + ' '.normal + "\n"
        lines << "#{comments}" if comments
      end

      error_report = lines.compact.join("\n") || 'Undefined error'

      self.out.puts(error_report) if error_report.present?
      self.exit_code = 1
    end

    def self.osx?
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
