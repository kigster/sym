require 'coin'
require 'digest'
require 'singleton'
require 'forwardable'
require 'colored2'

module Shhh
  module App
    module Password
      class Cache

        Coin.uri = 'druby://127.0.0.1:24924'

        attr_accessor :provider, :enabled, :timeout

        def initialize(provider: Coin, enabled: true, timeout: 300)
          self.provider = provider
          self.enabled  = enabled
          self.timeout  = timeout
        end

        def [] (key)
          provider.read(md5(key)) if self.enabled
        rescue StandardError => e
          puts 'WARNING: error reading from DRB server: ' + e.message.red
          nil
        end

        def []=(key, value)
          provider.write(md5(key), value, timeout) if self.enabled
        rescue StandardError => e
          puts 'WARNING: error reading from DRB server: ' + e.message.red
          nil
        end

        def md5(string)
          Digest::MD5.base64digest(string)
        end


      end
    end
  end
end
