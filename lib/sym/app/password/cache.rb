require 'coin'
require 'digest'
require 'singleton'
require 'colored2'

module Sym
  module App
    module Password
      class Cache
        URI             = 'druby://127.0.0.1:24924'
        DEFAULT_TIMEOUT = 300

        include Singleton

        attr_accessor :provider, :enabled, :timeout

        def configure(provider: Coin, enabled: true, timeout: DEFAULT_TIMEOUT)
          Coin.uri = URI if provider == Coin

          self.provider = provider
          self.enabled  = enabled
          self.timeout  = timeout

          self
        end

        TRIES = 2

        def operation
          retries ||= TRIES
          yield if self.enabled
        rescue StandardError => e
          if retries == TRIES && Coin.remote_uri.nil?
            Coin.remote_uri = URI if provider == Coin
            retries         -= 1
            retry
          end
          puts 'WARNING: error reading from DRB server: ' + e.message.red
          nil
        end


        def [] (key)
          cache = self
          operation do
            cache.provider.read(cache.md5(key))
          end
        end

        def []=(key, value)
          cache = self
          operation do
            cache.provider.write(cache.md5(key), value, cache.timeout)
          end
        end

        def md5(string)
          Digest::MD5.base64digest(string)
        end
      end
    end
  end
end
