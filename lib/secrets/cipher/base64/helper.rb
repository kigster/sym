require 'base64'
require_relative 'encoder'
require_relative 'decoder'
require 'openssl'
module Secrets
  module Cipher
    module Base64
      module Helper
        CIPHER = -> { ::OpenSSL::Cipher.new('aes-256-cbc') }

        # eg. create_cipher(secret, iv, :encrypt)
        def create_cipher(secret, iv, cipher_type)
          cipher = CIPHER.call
          cipher.send(cipher_type)
          iv         ||= cipher.random_iv
          cipher.iv  = iv
          cipher.key = secret

          [cipher, iv]
        end

        def update_cipher(cipher, value)
          data = cipher.update(value)
          data << cipher.final
          data
        end

        def base64_encode(encrypted_data, iv)
          Encoder.new(encrypted_data, iv).encode
        end

        def base64_decode(encoded_data)
          decoder = Decoder.new(encoded_data)
          decoder.decode
          [decoder.encrypted_data, decoder.iv]
        end
      end
    end
  end
end


