require 'sym/errors'
require 'base64'
require 'zlib'

require 'sym/data/wrapper_struct'
require 'sym/data/encoder'
require 'sym/data/decoder'

module Sym
  # This module is responsible for taking arbitrary data of any format, and safely compressing
  # the result of `Marshal.dump(data)` using Zlib, and then doing `#urlsafe_encode64` encoding
  # to convert it to a string,
  module Data
    def encode(data, compress: true)
      Encoder.new(data, compress).data_encoded
    end

    def decode(data_encoded, compress: nil)
      Decoder.new(data_encoded, compress).data
    end
  end
end

