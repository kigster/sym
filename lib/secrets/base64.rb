
Secrets.dir 'secrets/base64'

module Secrets
  # This module is responsible for baset64 encoding the encrypted data
  # so that it can be represented by a single-line string in a YAML file.
  module Base64

    NEWLINE_SEP= '㎏'
    FIELD_SEP= '%'

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


