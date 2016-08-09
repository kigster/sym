require 'singleton'

module Secrets
  module App
    class FakeTerminal
      APPENDER = ->(argument) { Secrets::App::FakeTerminal.instance.append(argument) }
      include Singleton
      attr_accessor :lines

      def self.create
        self.instance.clear!
        self.instance
      end

      def output_proc
        APPENDER
      end

      def append(arg)
        self.lines ||= []
        self.lines << arg.split("\n")
        self.lines.flatten!.compact!
      end

      alias_method :<<, :append

      def clear!
        self.lines = []
      end
    end
  end
end

