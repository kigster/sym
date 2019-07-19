module Sym
  module App

    class Args

      OPTIONS_REQUIRE_KEY    = %i(encrypt decrypt edit)
      OPTIONS_KEY_CREATED    = %i(generate)
      OPTIONS_SPECIFY_KEY    = %i(key interactive keychain)
      OPTIONS_SPECIFY_OUTPUT = %i(output quiet)

      attr_accessor :opts, :selected_options

      def initialize(opts)
        self.opts             = opts
        self.selected_options = opts.keys.select { |k| opts[k] }
      end

      def specify_key?
        do?(OPTIONS_SPECIFY_KEY)
      end

      def require_key?
        do?(OPTIONS_REQUIRE_KEY)
      end

      def generate_key?
        do?(OPTIONS_KEY_CREATED)
      end

      def output_class
        output_type = OPTIONS_SPECIFY_OUTPUT.find { |o| opts[o] } # includes nil
        Sym::App::Output.outputs[output_type]
      end

      def provided_options
        opts.to_hash.keys.select { |k| opts[k] }
      end

      private

      def do?(list)
        !(list & selected_options).empty?
      end

    end
  end
end
