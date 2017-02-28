require 'sym/app/private_key/base64_decoder'
require 'sym/app/private_key/decryptor'
require 'sym/app/private_key/reader'
require 'sym/app/input/handler'
require 'sym/app/args'
require 'sym/errors'
module Sym
  module App
    module PrivateKey
      # This class figures out what is the private key that is
      # provided to be used.
      class Handler < Struct.new(:opts, :input_handler, :password_cache)
        include Sym

        # @return [String] key Private key detected
        def key
          @key ||= detect_key
        end

        private

        def detect_key
          begin
            key = Reader.new(opts[:key], input_handler, password_cache).key
          rescue Sym::Errors::Error => e
            if Sym::App::Args.new(opts.to_h).specify_key? && key.nil?
              raise e
            end
          end

          if key
            if key.length > 45
              Decryptor.new(Base64Decoder.new(key).key, input_handler, password_cache).key
            else
              key
            end
          else
            nil
          end
        end
      end
    end
  end
end
