require 'base64'
require 'sym/cipher_handler'

module Sym
  module Extensions
    module ClassMethods
      def self.extended(klass)
        klass.extend Sym::CipherHandler::ClassMethods
      end
    end
  end
end
