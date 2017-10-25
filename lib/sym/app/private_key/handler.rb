require 'sym/app/private_key/base64_decoder'
require 'sym/app/private_key/decryptor'
require 'sym/app/private_key/detector'
require 'sym/app/input/handler'
require 'sym/app/args'
require 'sym/errors'
module Sym
  module App
    module PrivateKey
      # This class figures out what is the private key that is
      # provided to be used.
      class Handler < Struct.new(:opts, :input_handler, :password_cache)
        include Sym::Crypt
        attr_accessor :key, :key_source

        def initialize(*args)
          super(*args)
          self.key, self.key_source = detect_key
        end

        private

        def detect_key
          begin
            reader = Detector.new(opts, input_handler, password_cache)
            key = reader.key
            key_source = reader.key_source
          rescue Sym::Errors::Error => e
            if Sym::App::Args.new(opts.to_h).specify_key? && key.nil?
              raise e
            end
          end
          key = Decryptor.new(Base64Decoder.new(key).key, input_handler, password_cache).key if key && key.length > 45
          return key ? [key, key_source] : [nil, nil]
        end
      end
    end
  end
end
