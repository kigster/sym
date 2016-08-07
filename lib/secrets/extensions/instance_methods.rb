require 'secrets'
require 'secrets/base64'
require 'secrets/encrypted'

module Secrets
  module Extensions
    module InstanceMethods
      include Secrets::Base64
      include Secrets::Encrypted

      # Expects key to be a base64 encoded key value
      def encr(value, key = nil, iv = nil)
        raise Secrets::NoPrivateKeyFound.new unless key
        cipher, iv     = create_cipher(key, iv, :encrypt)
        encrypted_data = update_cipher(cipher, Marshal.dump(value))
        base64_encode(encrypted_data, iv)
      end

      # Expects key to be a base64 encoded key value
      def decr(value, key = nil)
        raise Secrets::NoPrivateKeyFound.new unless key
        encrypted_data, iv = base64_decode(value)
        cipher,            = create_cipher(key, iv, :decrypt)
        Marshal.load(update_cipher(cipher, encrypted_data))
      end
    end
  end
end
