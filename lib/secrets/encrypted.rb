
module Secrets
  module Encrypted

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
  end
end

