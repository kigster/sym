module Shhh
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
  #     Shhh::Configuration.configure do |config|
  #       config.password_cipher = 'AES-128-CBC'  #
  #       config.data_cipher = 'AES-256-CBC'
  #       config.private_key_cipher = config.data_cipher
  #       config.compression_enabled = true
  #       config.compression_level = Zlib::BEST_COMPRESSION
  #     end
  class Configuration
    class << self
      attr_accessor :config

      def configure
        self.config ||= Configuration.new
        yield config if block_given?
      end

      def property(name)
        self.config.send(name)
      end
    end

    attr_accessor :data_cipher, :password_cipher, :private_key_cipher
    attr_accessor :compression_enabled, :compression_level
  end
end
