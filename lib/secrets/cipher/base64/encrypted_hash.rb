require 'secrets/cipher/base64'
require 'active_support/inflector'
require 'hashie/mash'
require 'hashie/extensions/symbolize_keys'
module Secrets
  module Cipher
    module Base64
      class EncryptedHash < Hashie::Mash
        class UnsupportedTypeError < TypeError;
        end

        include Secrets::Cipher::Base64

        attr_accessor :encrypted, :decrypted
        SCALAR_TYPES = {
          Integer    => ->(string) { string.to_i },
          Float      => ->(string) { string.to_f },
          Fixnum     => ->(string) { string.to_i },
          Rational   => ->(string) { string.to_r },
          Complex    => ->(string) { string.to_c },
          Symbol     => ->(string) { string.to_sym },
          FalseClass => ->(*) { false },
          TrueClass  => ->(*) { true }
        }

        def encrypt(secret, hash = self)
          new_hash = self.class.new
          hash.each_pair do |key, value|
            new_hash[key] = if value.is_a?(Array)
                              value.map { |v| encr(v, secret) }
                            elsif value.is_a?(Hash)
                              encrypt(secret, value)
                            elsif value.is_a?(String)
                              encr(value, secret)
                            elsif value.nil?
                              value
                            elsif SCALAR_TYPES.keys.include?(value.class)
                              encr("<<DataType:#{value.class.name}>>#{value.to_s}", secret)
                            end
          end
          new_hash
        end

        def decrypt(secret, hash = self)
          new_hash = self.class.new
          hash.each_pair do |key, value|
            new_hash[key] = if value.is_a?(Array)
                              value.map { |v| decr(v, secret) }
                            elsif value.is_a?(Hash)
                              decrypt(secret, value)
                            elsif value.nil?
                              value
                            else
                              decrypted = decr(value, secret)
                              auto_detect_type(decrypted)
                            end
          end
          new_hash
        end

        private

        def auto_detect_type(decrypted)
          data_type_regex = %r{<<DataType:([^>]+)>>}
          if data_type_regex.match(decrypted)
            begin
              value_class = data_type_regex.match(decrypted)[1].constantize
              decrypted.gsub!(/<<DataType:[^>]+>>/, '')
              if SCALAR_TYPES[value_class]
                SCALAR_TYPES[value_class].call(decrypted)
              else
                raise UnsupportedTypeError.new("Value class #{value_class.name} is unsupported")
              end
            rescue Exception => e
              STDERR.puts "Error decrypting, instantiation of type #{value_class.name}(#{decrypted}) failed:\n#{e.message.bold.red}"
              raise(e)
            end
          else
            decrypted
          end
        end
      end
    end
  end
end
