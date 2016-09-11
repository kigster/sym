require_relative 'detector'
require_relative 'base64_decoder'
require_relative 'decryptor'
require_relative '../input/handler'
module Shhh
  module App
    module PrivateKey
      # This class figures out what is the private key that is
      # provided to be used.
      class Handler
        include Shhh

        attr_accessor :opts, :input_handler, :password_cache
        attr_writer :key

        def initialize(opts, input_handler, password_cache)
          self.opts           = opts
          self.input_handler  = input_handler
          self.password_cache = password_cache
        end


        # @return [String] key Private key detected
        def key
          return @key if @key

          @key = begin
            Detector.new(opts, input_handler).key
          rescue Shhh::Errors::Error => e
            if Shhh::App::Args.new(opts).do_options_specify_key? && key.nil?
              raise e
            end
          end

          if @key && @key.length > 45
            @key = Decryptor.new(Base64Decoder.new(key).key, input_handler, password_cache).key
          end

          @key
        end
      end
    end
  end
end
