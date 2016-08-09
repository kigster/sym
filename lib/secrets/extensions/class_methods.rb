require 'base64'
require 'secrets/cipher_handler'

module Secrets
  module Extensions
    module ClassMethods
      def self.extended(klass)
        klass.extend Secrets::CipherHandler::ClassMethods
      end
    end
  end
end
