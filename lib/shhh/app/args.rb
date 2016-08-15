module Shhh
  module App
    class Args < Struct.new(:opts, :argv)
      MODE = %i(encrypt decrypt generate edit keychain)
      KEY  = %i(private_key interactive keyfile keychain)
      OUTPUT = %i(output quiet)

      def mode?; is(MODE); end
      def key?; is(KEY); end

      def output_class
        output_type = OUTPUT.find{|o| opts[o] } # includes nil
        Shhh::App::Output.outputs[output_type]
      end

      private
      def is(list)
        !options_for(list).empty?
      end
      def options_for(of)
        of.map{ |o| opts[o] }.compact
      end

    end
  end
end
