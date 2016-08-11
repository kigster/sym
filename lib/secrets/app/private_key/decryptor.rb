require_relative 'decryptor'
module Secrets
  module App
    module PrivateKey
      class Decryptor
        include Secrets

        attr_accessor :encrypted_key, :input_handler

        def initialize(encrypted_key, input_handler = Secrets::App::Input::Handler)
          self.encrypted_key = encrypted_key
          self.input_handler = input_handler
        end

        def key
          return nil if encrypted_key.nil?
          decrypted_key = nil
          if should_decrypt?
            begin
              retries ||= 0
              decrypted_key = decrypt(password)
            rescue ::OpenSSL::Cipher::CipherError => e
              STDERR.puts 'Invalid password. Please try again.'
              ((retries += 1) < 3) ? retry : raise(Secrets::Errors::InvalidPasswordPrivateKey.new(e))
            end
          else
            decrypted_key = encrypted_key
          end
          decrypted_key
        end

        private

        def should_decrypt?
          encrypted_key && (encrypted_key.length > 32)
        end


        def decrypt(password)
          decr_password(encrypted_key, password)
        end

        def password
          input_handler.ask
        end

      end
    end
  end
end
