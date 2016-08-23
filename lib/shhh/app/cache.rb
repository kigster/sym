require 'coin'
require 'digest'
require 'singleton'
# # configure the URI that the DRb server runs on (defaults to druby://localhost:PORT)


module Shhh
  module App
    class Cache

      include Singleton

      class << self
        def configure
          Coin.uri = 'druby://127.0.0.1:24924'
        end
      end

      self.configure

      def md5(string)
        Digest::MD5.base64digest(string)
      end

      def [] (key)
        Coin.read(md5(key))
      end

      def []=(key, value)
        Coin.write(md5(key), value)
      end
    end
  end
end

