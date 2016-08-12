require 'singleton'
module Shhh
  module App
    class FakeTerminal
      APPENDER = ->(argument) { Shhh::App::FakeTerminal.instance.append(argument) }
      include Singleton
      attr_accessor :lines, :mutex


      def self.new_password
        self.instance.clear!
        self.instance
      end

      def output_proc
        APPENDER
      end

      def append(arg)
        return unless arg
        self.mutex ||= Mutex.new
        terminal = self
        mutex.synchronize do
          terminal.lines ||= []
          terminal.lines << arg.split("\n")
          terminal.lines.flatten!.compact!
        end
      end

      alias_method :<<, :append

      def clear!
        self.lines = []
      end

      private

      def new
        self.mutex = Mutex.new
        super
      end
    end
  end
end

