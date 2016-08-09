module Secrets
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
