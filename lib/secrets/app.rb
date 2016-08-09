require 'secrets/data'
require 'active_support/inflector'
module Secrets
  # This module is responsible for handing user input and executing commands
  # around the encryption
  module App
    class << self
      attr_accessor :exit_code
    end

    self.exit_code = 0

    def self.out
      STDERR
    end

    def self.error(
      config: {},
      exception: nil,
      type: nil,
      details: nil,
      reason: nil)

      self.out.puts([\
                    "#{(type || exception.class.name).titleize}:".red.bold.underlined +
                    (sprintf '  %-70.70s', details || exception.message).red.italic,
                    reason ? "\n#{reason.blue.bold.italic}" : nil].compact.join("\n"))
      self.out.puts "\n" + exception.backtrace.join("\n").bold.red if exception && config && config[:trace]
      self.exit_code = 1
    end
  end
end

Secrets.dir_r 'secrets/app'
