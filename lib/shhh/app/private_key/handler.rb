require_relative 'detector'
require_relative 'base64_decoder'
require_relative 'decryptor'
module Shhh
  module App
    module PrivateKey
      # This class figures out what is the private key that is
      # provided to be used.
      class Handler
        include Shhh

        attr_accessor :opts, :key

        def initialize(opts)
          self.opts = opts


          self.key =
            begin
              Detector.new(opts).key
            rescue Shhh::Errors::Error => e
              if Shhh::App::Args.new(opts).key? && key.nil?
                raise e
              end
            end

          if key && key.length > 45
            self.key = Decryptor.new(Base64Decoder.new(key).key).key
          end
        end
      end
    end
  end
end
