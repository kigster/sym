module Shhh
  module App
    module PrivateKey
      class Detector < Struct.new(:opts) # :nodoc:
        @mapping = Hash.new
        class << self
          attr_reader :mapping

          def register(argument, proc)
            self.mapping[argument] = proc
          end
        end

        def key
          self.class.mapping.each_pair do |options_key, key_proc|
            return key_proc.call(self.opts[options_key]) if self.opts[options_key]
          end
          nil
        end
      end

      Detector.register :private_key, ->(key) { key }
      Detector.register :interactive, -> { Input::Handler.prompt('Private Key: ', :magenta) }
      Detector.register :keychain, ->(key_name) { KeyChain.new(key_name).find }
      Detector.register :keyfile, ->(file) {
        begin
          ::File.read(file)
        rescue Errno::ENOENT
          raise Shhh::Errors::FileNotFound.new("Encryption key file #{file} was not found.")
        end
      }
    end
  end
end
