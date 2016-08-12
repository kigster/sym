require 'shhh/data'
require 'active_support/inflector'
module Shhh
  # The +App+ Module is responsible for handing user input and executing commands.
  # Central class in this module is the +CLI+ class.

  # This module is responsible for printing pretty errors and maintaining the
  # future exit code class-global variable.

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
                    (sprintf '  %s', details || exception.message).red.italic,
                    reason ? "\n#{reason.blue.bold.italic}" : nil].compact.join("\n"))
      self.out.puts "\n" + exception.backtrace.join("\n").bold.red if exception && config && config[:trace]
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

Shhh.dir_r 'shhh/app'
