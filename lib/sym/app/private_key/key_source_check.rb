require 'sym/app/private_key/base64_decoder'
require 'sym/app/private_key/decryptor'
require 'sym/app/input/handler'
require 'base64'

module Sym
  module App
    module PrivateKey
      class KeySourceResult < Struct.new(:name, :reducted, :input, :key)
        def to_s
          "#{name}://#{reducted ? '[reducted]' : input}"
        end
      end

      class KeySourceCheck
        attr_accessor :name, :reducted, :input, :output

        def initialize(name:,
                       output:, reducted: false,
                       input: ->(detector) { detector.opts[:key] })

          self.name     = name
          self.reducted = reducted
          self.input    = input
          self.output   = output
        end

        def detect(detector)
          input_value = input.call(detector)
          return nil unless input_value
          KeySourceResult.new(name,
                              reducted,
                              input_value,
                              output.call(detector, input_value))
        end

        CHECKS = [
          # Order of registration is important for auto-detect feature;
          # First proc is tried before the last; first one to succeed wins.
          KeySourceCheck.new(
            name:     :interactive,
            reducted: true,
            input:    ->(detector) { detector.opts[:interactive] },
            output:   ->(detector, *) { detector.input_handler.prompt('Please paste your private key: ', :magenta) }
          ),

          KeySourceCheck.new(
            name:   :file,
            output: ->(*, value) { ::File.read(value).chomp if value && File.exist?(value) }
          ),

          KeySourceCheck.new(
            name:   :keychain,
            output: ->(*, value) { KeyChain.get(value) if value }
          ),

          KeySourceCheck.new(
            name:     :string,
            reducted: true,
            output:   ->(*, value) do
              decoded = begin
                Base64Decoder.new(value).key
              rescue
                nil
              end
              value if decoded
            end
          ),

          KeySourceCheck.new(
            name:   :env,
            output: ->(*, value) { ENV[value] if value =~ /^[a-zA-Z0-9_]+$/ }
          ),

          KeySourceCheck.new(
            name:   :default_file,
            input:  ->(*) { Sym.default_key_file if Sym.default_key? },
            output: ->(detector, *) {
              key_provided_by = %i(key interactive) &
                                detector.opts.to_hash.keys.select { |k| detector.opts[k] }
              Sym.default_key if key_provided_by.empty?
            }
          )
        ]
      end
    end
  end
end
