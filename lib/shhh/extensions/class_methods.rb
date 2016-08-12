require 'base64'
require 'shhh/cipher_handler'

module Shhh
  module Extensions
    module ClassMethods
      def self.extended(klass)
        klass.extend Shhh::CipherHandler::ClassMethods
      end
    end
  end
end
