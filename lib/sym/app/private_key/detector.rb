require 'sym/app/private_key/base64_decoder'
require 'sym/app/private_key/decryptor'
require 'sym/app/private_key/key_source_check'
require 'sym/app/input/handler'

module Sym
  module App
    module PrivateKey
      class Detector < Struct.new(:opts, :input_handler, :password_cache)
        attr_accessor :key, :key_source

        def initialize(*args)
          super(*args)
          read
        end

        def read
          return key if key
          self.key, self.key_source = read!
        end

        # Returns the first valid 32-bit key obtained by running the above
        # procs on a given string.
        def read!
          KeySourceCheck::CHECKS.each do |source_check|
            if result = source_check.detect(self) rescue nil
              if key_ = normalize_key(result.key)
                key_source_ = result.to_s
                return key_, key_source_
              end
            end
          end
          nil
        end

        private

        def normalize_key(key)
          return nil if key.nil?
          if key && key.length > 45
            key = Decryptor.new(Base64Decoder.new(key).key, input_handler, password_cache).key
          end
          validate(key)
        end

        def validate(key)
          if key
            begin
              decoded = Base64Decoder.new(key).key
              decoded.length == 32 ? key : nil
            rescue
              nil
            end
          else
            nil
          end
        end
      end
    end
  end
end
