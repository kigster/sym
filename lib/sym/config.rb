require 'sym/crypt/configuration'
require 'sym/configurable'

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
#     Sym::Config.configure do |config|
#       config.password_cipher = 'AES-128-CBC'  #
#       config.data_cipher = 'AES-256-CBC'
#       config.private_key_cipher = config.data_cipher
#       config.compression_enabled = true
#       config.compression_level = Zlib::BEST_COMPRESSION
#     end
module Sym

  class Config < Crypt::Configuration
     = ->(config) do
      Crypt::Configuration::DEFAULTS[config]

      # The rest is defined in Sym::Config
      config.encrypted_file_extension = 'enc'
      config.default_key_file         = Sym::Constants::SYM_KEY_FILE

      config.password_cache_timeout          = 300

      # When nil is selected, providers are auto-detected.
      config.password_cache_default_provider = nil
      config.password_cache_arguments        = {
        drb:       {
          opts: {
            uri: 'druby://127.0.0.1:24924'
          }
        },
        memcached: {
          args: %w(127.0.0.1:11211),
          opts: { namespace:  'sym',
                  compress:   true,
                  expires_in: config.password_cache_timeout
          }

        }
      }
    end

    include Configurable
    # See file +lib/sym.rb+ where these values are defined.

    attr_accessor :password_cache_default_provider,
                  :password_cache_timeout,
                  :password_cache_arguments,
                  :default_key_file,
                  :encrypted_file_extension

  end
end
