require_relative '../errors'
require 'base64'
require 'zlib'
module Secrets
  module Data
    class Decoder
      attr_accessor :data, :data_encoded, :data

      def initialize(data_encoded, compress)
        self.data_encoded = data_encoded
        self.data         = Base64.urlsafe_decode64(data_encoded)

        if compress.nil? || compress # auto-guess
          self.data = begin
            Zlib::Inflate.inflate(data)
          rescue Zlib::Error => e
            data
          end
        end
        self.data = Marshal.load(data)
      end
    end
  end
end
