require 'singleton'

module Sym
  module App
    class FakeTerminal

      include Singleton

      class << self

        def console
          instance.tap do |c|
            c.mutex
            if ENV['DEBUG']

            end
          end
        end

        def appender(console = instance)
          ->(argument) { console.append(argument) }
        end

        def new_password
          instance.clear!
          instance
        end
      end

      attr_reader :lines

      def clear!
        mutex.synchronize do
          @lines = []
        end
      end

      def output_proc
        self.class.appender(self)
      end

      def append(arg = nil)
        return unless arg

        mutex.synchronize do
          @lines ||= []
          @lines << arg.split("\n")
          @lines.flatten!.compact!
        end
      end

      alias :<< :append

      def puts(*args)
        append(args.join)
      end

      private

      def mutex
        @mutex ||= Mutex.new
      end
    end
  end
end
