require_relative 'detector'
require_relative 'base64_decoder'
require_relative 'decryptor'
module Secrets
  module App
    module PrivateKey
      class Handler
        include Secrets

        attr_accessor :opts, :key

        def initialize(opts)
          self.opts = opts
          self.key  = Decryptor.new(
                        Base64Decoder.new(
                          Detector.new(
                            opts
                          ).key
                        ).key
                      ).key
        end

      end
    end
  end
end
