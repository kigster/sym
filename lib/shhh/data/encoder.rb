require 'base64'
require 'zlib'

require 'shhh/errors'
require 'shhh/configuration'

module Shhh
  module Data
    class Encoder
      attr_accessor :data, :data_encoded

      def initialize(data, compress)
        self.data         = data
        self.data_encoded = Marshal.dump(data)
        self.data_encoded = Zlib::Deflate.deflate(data_encoded, compression_level) if compress
        self.data_encoded = Base64.urlsafe_encode64(data_encoded)
      end

      def compression_level
        Shhh::Configuration.config.compression_level
      end
    end
  end
end
