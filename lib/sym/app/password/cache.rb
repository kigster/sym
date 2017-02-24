require 'digest'
require 'singleton'
require 'colored2'
require 'timeout'
require 'sym/extensions/with_retry'
require 'sym/extensions/with_timeout'
require 'sym/configuration'
require 'sym/app/password/providers'

module Sym
  module App
    module Password

      # +Provider+ is the primary implementation of the underlying cache.
      # It should support the following API:
      #
      #        def initialize(*args, **opts, &block)
      #        end
      #
      #        def read(key)
      #        end
      #
      #        def write(key, value, expire_timeout_seconds)
      #        end
      #
      # it must be intantiatable via #new
      class Cache

        include Singleton
        include Sym::Extensions::WithRetry
        include Sym::Extensions::WithTimeout

        attr_accessor :provider, :enabled, :timeout, :verbose

        def configure(**opts)
          self.enabled = opts[:enabled]
          self.verbose = opts[:verbose]
          self.timeout = opts[:timeout] || ::Sym::Configuration.config.password_cache_timeout
          self.provider = Providers.provider(opts[:provider], opts[:provider_opts] || {})
          self.enabled = false unless self.provider
          self
        end

        def [](key)
          cache = self
          operation { cache.provider.read(cache.md5(key)) }
        end

        def []=(key, value)
          cache = self
          operation { cache.provider.write(cache.md5(key), value, cache.timeout) }
        end

        def md5(string)
          Digest::MD5.base64digest(string)
        end

        private

        def operation
          return nil unless self.enabled
          with_timeout(1) do
            with_retry do
              yield if block_given?
            end
          end
        rescue Timeout::Error => e
          error(nil, 'Password cache server timed out...')
        rescue StandardError => e
          error(e, 'Error connecting to password caching server...')
        end

        def error(exception = nil, message = nil)
          if self.verbose
            print 'WARNING: '
            print message ? message.yellow : ''
            print exception ? exception.message.red : ''
            puts
          end
          self.enabled = false
          nil
        end
      end
    end
  end
end
