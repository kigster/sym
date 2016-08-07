require 'secrets/base64'

module Secrets
  # This module is responsible for handing user input and executing commands
  # around the encryption
  module App
    class << self
      attr_accessor :exit_code
    end

    self.exit_code = 0

    def self.error(
      config: {},
      exception: nil,
      type: nil,
      details: nil,
      reason: nil)

      STDERR.puts([\
                    "#{type || exception.class.name}".yellow.bold.underlined,
                    'Details:  ' + (details || exception.message).red.italic,
                    reason ? "Reason:   #{reason.yellow.bold}" : nil].compact.join("\n"))
      STDERR.puts exception.backtrace.join("\n").red if exception && config && config[:verbose]
      self.exit_code = 1
    end
  end
end

Secrets.dir_r 'secrets/app'
