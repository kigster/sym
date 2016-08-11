module Secrets
  module App
    class Args < Struct.new(:opts)
      MODE = %i(encrypt decrypt generate edit keychain)
      KEY  = %i(private_key interactive keyfile keychain)

      def mode?; is MODE; end
      def key?; is KEY; end

      private
      def is(list)
        list.any?{ |o| opts[o] }
      end

    end
  end
end
