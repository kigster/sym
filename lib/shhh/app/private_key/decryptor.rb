require_relative 'decryptor'
require 'shhh/app/cache'
module Shhh
  module App
    module PrivateKey
      class Decryptor
        include Shhh

        attr_accessor :encrypted_key, :input_handler

        def initialize(encrypted_key, input_handler)
          self.encrypted_key = encrypted_key
          self.input_handler = input_handler
          @cache_checked = false
        end

        def key
          return nil if encrypted_key.nil?
          decrypted_key = nil
          if should_decrypt?
            begin
              retries ||= 0

              p = password
              decrypted_key = decrypt(p)
              # if the password is valid, let's add it to the cache.
              Shhh::App::Cache.instance[encrypted_key] = p

            rescue ::OpenSSL::Cipher::CipherError => e
              input_handler.puts 'Invalid password. Please try again.'
              ((retries += 1) < 3) ? retry : raise(Shhh::Errors::InvalidPasswordPrivateKey.new('Invalid password.'))
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
          check_cache || ask_user
        end

        def ask_user
          input_handler.ask
        end

        def check_cache
          return nil if @cache_checked
          @cache_checked = true
          Shhh::App::Cache.instance[encrypted_key]
        end

      end
    end
  end
end
