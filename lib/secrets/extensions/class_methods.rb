require 'base64'
require 'secrets/encrypted'

module Secrets
  module Extensions
    module ClassMethods
      def create_private_key
        ::Base64.encode64(Secrets::Encrypted::CIPHER.call.random_key)
      end
    end
  end
end
