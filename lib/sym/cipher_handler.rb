require 'base64'
require 'sym/configuration'

module Sym

  # {Sym::CipherHandler} contains cipher-related utilities necessary to create
  # ciphers, and seed them with the salt or iV vector. It also defines the
  # internal structure {Sym::CipherHandler::CipherStruct} which is a key
  # struct used in constructing cipher and saving it with the data packet.
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
        key = CREATE_CIPHER.call(Sym::Configuration.property(:private_key_cipher)).random_key
        ::Base64.urlsafe_encode64(key)
      end
    end
  end
end

