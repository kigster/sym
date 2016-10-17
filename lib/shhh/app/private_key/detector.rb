module Shhh
  module App
    module PrivateKey
      class Detector < Struct.new(:opts, :input_handler) # :nodoc:s
        @mapping = Hash.new
        class << self
          attr_reader :mapping

          def register(argument, proc)
            self.mapping[argument] = proc
          end
        end

        def key
          self.class.mapping.each_pair do |options_key, key_proc|
            return key_proc.call(opts[options_key], self) if opts[options_key]
          end
          nil
        end
      end

      Detector.register :private_key,
                        ->(key, *) { key }

      Detector.register :interactive,
                        ->(*, detector) { detector.input_handler.prompt('Please paste your private key: ', :magenta) }

      Detector.register :keychain,
                        ->(key_name, * ) { KeyChain.new(key_name).find rescue nil }

      Detector.register :keyfile,
                        ->(file, *) {
        begin
          ::File.read(file)
        rescue Errno::ENOENT
          raise Shhh::Errors::FileNotFound.new("Encryption key file #{file} was not found.")
          nil
        end
      }
    end
  end
end
