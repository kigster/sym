require 'secrets/cipher/base64'

module Secrets
  module Cipher
    module Base64
      class EncryptedData

        class UsageError < ArgumentError
          def initialize *args
            super('Invalid arguments – expected either encrypted or decrypted with a secret')
          end
        end

        include Secrets::Cipher::Base64

        attr_accessor :iv, :encrypted, :decrypted

        def initialize(encrypted: nil, decrypted: nil, secret: nil)
          if encrypted && secret
            self.encrypted = encrypted
            self.decrypted = decr(encrypted, secret)
          elsif decrypted && secret
            self.decrypted = decrypted
            self.encrypted = encr(decrypted, secret)
          else
            raise UsageError.new
          end
        end
      end
    end
  end
end
