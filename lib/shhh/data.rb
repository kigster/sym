require_relative 'errors'
require 'base64'
require 'zlib'

require_relative 'data/wrapper_struct'
require_relative 'data/encoder'
require_relative 'data/decoder'

module Shhh
  # This module is responsible for taking arbitrary data of any format, and safely compressing
  # the result of `Marshal.dump(data)` using Zlib, and then doing `#urlsafe_encode64` encoding
  # to convert it to a string,
  module Data
    def encode(data, compress = true)
      Encoder.new(data, compress).data_encoded
    end

    def decode(data_encoded, compress = nil)
      Decoder.new(data_encoded, compress).data
    end
  end
end

