require 'sym'
require 'sym/data'
require 'sym/cipher_handler'
require 'openssl'
module Sym
  module Extensions
    # This is the module that is really included in your class
    # when you include +Sym+.
    #
    # The module provides easy access to the encryption configuration
    # via the +#encryption_config+ method, as well as two key
    # methods: +#encr+ and +#decr+.
    #
    # Methods +#encr_password+ and +#decr_password+ provide a good
    # example of how this module can be extended to provide more uses
    # of various ciphers, by calling into the private +_encr+ and +_decr+
    # methods.f
    module InstanceMethods
      include Sym::Data
      include Sym::CipherHandler

      def encryption_config
        Sym::Configuration.config
      end

      # Expects key to be a base64 encoded key
      def encr(data, key, iv = nil)
        raise Sym::Errors::NoPrivateKeyFound unless key.present?
        raise Sym::Errors::NoDataProvided unless data.present?
        encrypt_data(data, encryption_config.data_cipher, iv) do |cipher_struct|
          cipher_struct.cipher.key = decode_key(key)
        end
      end

      # Expects key to be a base64 encoded key
      def decr(encrypted_data, key, iv = nil)
        raise Sym::Errors::NoPrivateKeyFound unless key.present?
        raise Sym::Errors::NoDataProvided unless encrypted_data.present?
        decrypt_data(encrypted_data, encryption_config.data_cipher, iv) do |cipher_struct|
          cipher_struct.cipher.key = decode_key(key)
        end
      end

      def encr_password(data, password, iv = nil)
        raise Sym::Errors::NoDataProvided unless data.present?
        raise Sym::Errors::NoPasswordProvided unless password.present?
        encrypt_data(data, encryption_config.password_cipher, iv) do |cipher_struct|
          key, salt                = make_password_key(cipher_struct.cipher, password)
          cipher_struct.cipher.key = key
          cipher_struct.salt       = salt
        end
      end

      def decr_password(encrypted_data, password, iv = nil)
        raise Sym::Errors::NoDataProvided unless encrypted_data.present?
        raise Sym::Errors::NoPasswordProvided unless password.present?
        decrypt_data(encrypted_data, encryption_config.password_cipher, iv) do |cipher_struct|
          key,                     = make_password_key(cipher_struct.cipher, password, cipher_struct.salt)
          cipher_struct.cipher.key = key
        end
      end

      private

      def decode_key(encoded_key)
        Base64.urlsafe_decode64(encoded_key)
      rescue
        encoded_key
      end

      def make_password_key(cipher, password, salt = nil)
        key_len = cipher.key_len
        salt    ||= OpenSSL::Random.random_bytes 16
        iter    = 20_000
        digest  = OpenSSL::Digest.new('SHA256')
        key     = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iter, key_len, digest)
        return key, salt
      end

      # Expects key to be a base64 encoded key data
      def encrypt_data(data, cipher_name, iv = nil, &block)
        data, compression_enabled = encode_incoming_data(data)
        cipher_struct             = create_cipher(direction:   :encrypt,
                                                  cipher_name: cipher_name,
                                                  iv:          iv)

        block.call(cipher_struct) if block
 
        encrypted_data = update_cipher(cipher_struct.cipher, data)
        arguments      = { encrypted_data: encrypted_data,
                           iv:             cipher_struct.iv,
                           cipher_name:    cipher_struct.cipher.name,
                           salt:           cipher_struct.salt,
                           compress:       !compression_enabled }
        wrapper_struct = WrapperStruct.new(**arguments)
        encode(wrapper_struct, compress: false)
      end

      # Expects key to be a base64 encoded key data
      def decrypt_data(encoded_data, cipher_name, iv = nil, &block)
        wrapper_struct = decode(encoded_data)
        cipher_struct  = create_cipher(cipher_name: cipher_name,
                                       iv:          wrapper_struct.iv || iv,
                                       direction:   :decrypt,
                                       salt:        wrapper_struct.salt)
        block.call(cipher_struct) if block
        decode(update_cipher(cipher_struct.cipher, wrapper_struct.encrypted_data))
      end

      def encode_incoming_data(data)
        compression_enabled = !data.respond_to?(:size) || (data.size > 100 && encryption_config.compression_enabled)
        data                = encode(data, compress: compression_enabled)
        [data, compression_enabled]
      end

    end
  end
end

