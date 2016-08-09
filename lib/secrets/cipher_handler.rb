require 'base64'
require_relative 'configuration'

module Secrets
  #
  # +CipherHandler+ contains cipher-related utilities necessary to create
  # ciphers, and seed them with the salt or iV vector,
  #
  module CipherHandler

    CREATE_CIPHER = ->(name) { ::OpenSSL::Cipher.new(name) }

    CipherStruct = Struct.new(:cipher, :iv, :salt)

    def create_cipher(direction:,
                      cipher_name:,
                      iv: nil,
                      salt: nil)

      cipher = new_cipher(cipher_name)
      cipher.send(direction)
      iv        ||= cipher.random_iv
      cipher.iv = iv
      CipherStruct.new(cipher, iv, salt)
    end

    def new_cipher(cipher_name)
      CREATE_CIPHER.call(cipher_name)
    end

    def update_cipher(cipher, value)
      data = cipher.update(value)
      data << cipher.final
      data
    end

    module ClassMethods
      def create_private_key
        key = CREATE_CIPHER.call(Secrets::Configuration.property(:private_key_cipher)).random_key
        ::Base64.urlsafe_encode64(key)
      end
    end
  end
end

