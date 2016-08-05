require 'base64'
require_relative 'helper'
module Secrets
  module Cipher
    module Base64
      Encoder = Struct.new(:encrypted_data, :iv) do
        attr_accessor :encoded
        def encode
          self.encoded ||=
            ::Base64.encode64(
              ::Base64.encode64(self.encrypted_data) +
                FIELD_SEP +
              ::Base64.encode64(self.iv)
            ).gsub("\n", NEWLINE_SEP)
        end
      end
    end
  end
end
