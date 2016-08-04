require_relative '../helper'
require_relative '../exceptions'

module Secrets
  module Cipher
    module Base64
      module Extensions
        module InstanceMethods
          include Secrets::Cipher::Base64::Helper

          # Expects secret to be a base64 encoded secret value
          def encr(value, secret = nil, iv = nil)
            secret     = get_secret(secret)
            cipher, iv = create_cipher(secret, iv, :encrypt)
            encrypted_data = update_cipher(cipher, value)
            base64_encode(encrypted_data, iv)
          end

          # Expects secret to be a base64 encoded secret value
          def decr(value, secret = nil)
            encrypted_data, iv = base64_decode(value)
            secret             = get_secret(secret)
            cipher,            = create_cipher(secret, iv, :decrypt)
            update_cipher(cipher, encrypted_data)
          end

          private

          def get_secret(secret)
            unless secret
              if self.class.respond_to?(:secret)
                secret = self.class.secret
              end
            end
            raise Secrets::Cipher::Base64::SecretIsNotDefinedError.new unless secret
            ::Base64.decode64(secret)
          end
        end
      end
    end
  end
end
