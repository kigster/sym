require 'forwardable'
require 'dalli'

module Sym
  module App
    module Password
      class MemcachedProvider
        attr_accessor :dalli

        def initialize
          self.dalli = ::Dalli::Client.new(
            * Sym::Configuration.config.password_cache_memcached_provider[:args],
            ** Sym::Configuration.config.password_cache_memcached_provider[:opts]
          )
        end

        def read(key)
          dalli.get(key)
        end

        def write(key, value, expire_timeout_seconds)
          dalli.set(key, value)
        end
      end
    end
  end
end
