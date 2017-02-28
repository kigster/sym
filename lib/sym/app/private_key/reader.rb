require 'sym/app/private_key/base64_decoder'
require 'sym/app/private_key/decryptor'
require 'sym/app/input/handler'
require 'sym/extensions/ordered_hash'
require 'set'

module Sym
  module App
    module PrivateKey
      # Reader attempts to read private key from various places
      # given a single input string
      class Reader < Struct.new(:data, :input_handler, :password_cache)
        @readers = ::Sym::OrderedHash.new
        class << self
          attr_reader :readers

          def <<(name, proc)
            self.readers[name] = proc
          end
        end

        # Order of registration is important for auto-detect feature;
        # First proc is tried before the last; first one to succeed wins.
        Reader.<< :file, ->(file, *) { ::File.read(file).chomp rescue nil }
        Reader.<< :env, ->(key, *) { ENV[key] }
        Reader.<< :keychain, ->(key_name, *) { KeyChain.get(key_name) rescue nil }
        Reader.<< :string, ->(key, *) { key }

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
          key_        = nil
          key_source_ = nil
          self.class.readers.each_pair do |name, key_proc|
            key_ = begin
              key_proc.call(data)
            rescue
              nil
            end
            if key_
              key_ = normalize_key(key_)
              key_ && key_source_ = name && break
            end
          end
          return key_, key_source_
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
