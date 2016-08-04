require 'base64'
require_relative 'helper'
module Secrets
  module Cipher
    module Base64

      Decoder = Struct.new(:encoded_data) do
        attr_accessor :encrypted_data, :iv

        # Returns an array of [ encrypted_data, iv ]
        def decode
          result = ::Base64.decode64(self.encoded_data.gsub('%', "\n")).
            split(/\n\n/).
            map{ |v| ::Base64.decode64(v) }

          self.encrypted_data, self.iv = result

          result
        end
      end
      
    end
  end
end
