require 'secrets'
require 'secrets/data'
require 'secrets/cipher_handler'
require 'openssl'
module Secrets
  module Extensions
    module InstanceMethods
      include Secrets::Data
      include Secrets::CipherHandler

      def encryption_config
        Secrets::Configuration.config
      end

      # Expects key to be a base64 encoded key
      def encr(data, key, iv = nil)
        _encr(data, encryption_config.data_cipher, iv) do |cipher_struct|
          cipher_struct.cipher.key = decode_key(key)
        end
      end

      # Expects key to be a base64 encoded key
      def decr(encrypted_data, key, iv = nil)
        _decr(encrypted_data, encryption_config.data_cipher, iv) do |cipher_struct|
          cipher_struct.cipher.key = decode_key(key)
        end
      end

      def encr_password(data, password, iv = nil)
        _encr(data, encryption_config.password_cipher, iv) do |cipher_struct|
          key, salt                = _key_from_password(cipher_struct.cipher, password)
          cipher_struct.cipher.key = key
          cipher_struct.salt       = salt
        end
      end

      def decr_password(encrypted_data, password, iv = nil)
        _decr(encrypted_data, encryption_config.password_cipher, iv) do |cipher_struct|
          key,                     = _key_from_password(cipher_struct.cipher, password, cipher_struct.salt)
          cipher_struct.cipher.key = key
        end
      end

      private

      def decode_key(encoded_key)
        Base64.urlsafe_decode64(encoded_key)
      end

      def _key_from_password(cipher, password, salt = nil)
        key_len = cipher.key_len
        salt    ||= OpenSSL::Random.random_bytes 16
        iter    = 20000
        digest  = OpenSSL::Digest::SHA256.new
        key     = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iter, key_len, digest)
        return key, salt
      end


      # Expects key to be a base64 encoded key data
      def _decr(encoded_data, cipher_name, iv = nil, &block)
        wrapper_struct = decode(encoded_data)
        cipher_struct  = create_cipher(cipher_name: cipher_name,
                                       iv:          wrapper_struct.iv,
                                       direction:   :decrypt,
                                       salt:        wrapper_struct.salt)
        yield cipher_struct if block_given?
        decode(update_cipher(cipher_struct.cipher, wrapper_struct.encrypted_data))
      end

      # Expects key to be a base64 encoded key data
      def _encr(data, cipher_name, iv = nil, &block)
        data, compression_enabled = encode_incoming_data(data)
        cipher_struct             = create_cipher(direction:   :encrypt,
                                                  cipher_name: cipher_name,
                                                  iv:          iv)

        yield cipher_struct if block_given?

        encrypted_data = update_cipher(cipher_struct.cipher, data)
        wrapper_struct = WrapperStruct.new(
          encrypted_data: encrypted_data,
          iv:             cipher_struct.iv,
          cipher_name:    cipher_struct.cipher.name,
          salt:           cipher_struct.salt,
          compress:       !compression_enabled)
        encode(wrapper_struct, false)
      end

      def encode_incoming_data(data)
        compression_enabled = !data.respond_to?(:size) || (data.size > 100 && encryption_config.compression_enabled)
        data                = encode(data, compression_enabled)
        [data, compression_enabled]
      end

    end
  end
end

