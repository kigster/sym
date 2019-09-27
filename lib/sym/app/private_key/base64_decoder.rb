# frozen_string_literal: true

require 'base64'
module Sym
  module App
    module PrivateKey
      class Base64Decoder < Struct.new(:encoded_key)
        def key
          return nil if encoded_key.nil?

          begin
            Base64.urlsafe_decode64(encoded_key)
          rescue ArgumentError
            encoded_key
          end
        end
      end
    end
  end
end
