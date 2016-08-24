require 'coin'
require 'digest'
require 'singleton'

module Shhh
  module App
    #
    # +Cache+ looks like a hash, but is a singleton, and provides
    # access to the shared across processes Cache.
    #
    # The current implementation is based on DRb, which creates a
    # server process that then manages the data structure.
    #
    class Cache
      include Singleton

      class << self
        def cache
          self.instance
        end

        def configure
          # configure the URI that the DRb server runs on
          Coin.uri = 'druby://127.0.0.1:24924'
        end
      end

      self.configure

      def [] (key)
        Coin.read(md5(key))
      end

      def []=(key, value)
        Coin.write(md5(key), value)
      end

      private

      def md5(string)
        Digest::MD5.base64digest(string)
      end

    end
  end
end

