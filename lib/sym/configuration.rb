require 'sym/crypt/configuration'

module Sym
  # This class encapsulates application configuration, and exports
  # a familiar method +#configure+ for defining configuration in a
  # block.
  #
  # It's values are requested by the library upon encryption or
  # decryption, or any other operation.
  #
  # == Example
  #
  # The following is an actual initialization from the code of this
  # library. You may override any of the value defined below in your
  # code, but _before_ you _use_ library's encryption methods.
  #
  #     Sym::Configuration.configure do |config|
  #       config.password_cipher = 'AES-128-CBC'  #
  #       config.data_cipher = 'AES-256-CBC'
  #       config.private_key_cipher = config.data_cipher
  #       config.compression_enabled = true``
  #       config.compression_level = Zlib::BEST_COMPRESSION
  #     end
  class Configuration < ::Sym::Crypt::Configuration

    attr_accessor :password_cache_default_provider,
                  :password_cache_timeout,
                  :password_cache_arguments,
                  :default_key_file,
                  :encrypted_file_extension

    def initialize
      super
      reset_to_defaults!
    end

    def reset_to_defaults!
      super

      self.encrypted_file_extension = 'enc'
      self.default_key_file         = ::Sym::Constants::SYM_KEY_FILE
      self.password_cache_timeout   = ::Sym::Constants::DEFAULT_CACHE_TTL

      # When nil is selected, providers are auto-detected.
      self.password_cache_default_provider = nil
      self.password_cache_arguments        = {
        memcached: {
          args: %w(127.0.0.1:11211),
          opts: { namespace:  'sym',
                  compress:   true,
                  expires_in: password_cache_timeout
          }

        }
      }
    end
  end
end
