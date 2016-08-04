require 'base64'

module Secrets
  module Cipher
    module Base64
      module InstanceMethods

        def encr(value, secret, iv = nil)
          cipher = create_cipher
          cipher.encrypt
          cipher.key = secret
          iv ? cipher.iv = iv : iv = cipher.random_iv
          encrypted_data = cipher.update(value)
          encrypted_data << cipher.final

          base64_encode(iv, encrypted_data)
        end

        def decr(value, secret)
          cipher = create_cipher
          cipher.decrypt
          cipher.key         = secret
          encrypted_data, iv = base64_decode(value)
          cipher.iv          = iv
          decrypted_data     = cipher.update(encrypted_data)
          decrypted_data << cipher.final
        end

        private

        def create_cipher
          OpenSSL::Cipher.new('aes-256-cbc')
        end

        def base64_encode(iv, encrypted_data)
          ::Base64.encode64(::Base64.encode64(encrypted_data) + '|' + ::Base64.encode64(iv))
        end

        # Returns an array of [ encrypted_data, iv ]
        def base64_decode(encoded_data)
          ::Base64.decode64(encoded_data).split(/\|/).map{ |v| ::Base64.decode64(v) }
        end
      end

      module ClassMethods

        def generate_secret
          OpenSSL::Cipher.new('aes-256-cbc').random_key
        end

        def attr_encrypted *attributes

        end
      end
    end
  end
end
