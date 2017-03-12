require 'forwardable'
require 'dalli'

module Sym
  module App
    module Password
      module Providers
        class MemcachedProvider
          attr_accessor :dalli

          def initialize(**opts)
            # disable logging
            Dalli.logger = Sym::Constants::Log::NIL
            self.dalli = ::Dalli::Client.new(
              * Sym::Configuration.config.password_cache_arguments[:memcached][:args],
              ** Sym::Configuration.config.password_cache_arguments[:memcached][:opts].merge!(opts)
            )
          end

          def alive?
            dalli.alive!
            true
          rescue Dalli::RingError => e
            false
          end

          def read(key)
            dalli.get(key)
          end

          def write(key, value, *)
            dalli.set(key, value)
          end

          def clear
            dalli.flush
          end

        end

        register MemcachedProvider
      end
    end
  end
end
