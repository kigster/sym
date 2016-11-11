require 'singleton'
module Sym
  module App
    class FakeTerminal
      def self.appender(console)
        ->(argument) { console.append(argument) }
      end

      attr_accessor :lines, :mutex

      def self.new_password
        self.instance.clear!
        self.instance
      end

      def output_proc
        self.class.appender(self)
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

      def puts(*args)
        append(args.join)
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

