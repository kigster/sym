require 'sym/app/private_key/decryptor'
require 'sym/app/password/cache'
module Sym
  module App
    module PrivateKey
      class Decryptor
        include Sym

        attr_accessor :encrypted_key, :input_handler, :password_cache

        def initialize(encrypted_key, input_handler, password_cache)
          self.encrypted_key  = encrypted_key
          self.input_handler  = input_handler
          self.password_cache = password_cache
          @cache_checked      = false
        end

        def key
          return nil if encrypted_key.nil?
          decrypted_key = nil
          if should_decrypt?
            begin
              retries                                   ||= 0
              p                                         = determine_key_password
              decrypted_key                             = decrypt(p)

              # if the password is valid, let's add it to the cache.
              password_cache[encrypted_key] = p

            rescue ::OpenSSL::Cipher::CipherError => e
              input_handler.puts 'Invalid password. Please try again.'

              if ((retries += 1) < 3)
                retry
              else
                raise(Sym::Errors::InvalidPasswordPrivateKey.new('Invalid password.'))
              end
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

        def determine_key_password
          check_cache || ask_user
        end

        def ask_user
          input_handler.ask
        end

        def check_cache
          return nil if @cache_checked
          @cache_checked = true
          password_cache[encrypted_key]
        end
      end
    end
  end
end
