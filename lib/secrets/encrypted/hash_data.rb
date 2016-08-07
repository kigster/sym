require 'active_support/inflector'
require 'hashie/mash'
require 'hashie/extensions/symbolize_keys'

module Secrets
  module Encrypted
    class HashData < AbstractData

      def self.supports?(data)
        data.is_a?(Hash) || data.respond_to?(:keys)
      end

      def encrypt(secret)
        recursive_encrypt(secret)
      end

      def decrypt(secret)
        recursive_decrypt(secret)
      end

      private

      def recursive_encrypt(secret, hash = self.data)
        new_hash = Hash.new
        hash.each_pair do |key, value|
          new_hash[key] = if value.is_a?(Array)
                            value.map { |v| encr(v, secret) }
                          elsif self.class.supports?(value)
                            recursive_encrypt(secret, value)
                          elsif value.nil?
                            nil
                          elsif ScalarData.supports?(value)
                            ScalarData.new(value).encrypt(secret)
                          else
                            raise Secrets::Errors::UnsupportedType.new(value.class)
                          end
        end
        new_hash
      end

      def recursive_decrypt(secret, hash = self.data)
        new_hash = Hash.new
        hash.each_pair do |key, value|
          new_hash[key] = if self.class.supports?(value)
                            recursive_decrypt(secret, value)
                          elsif value.is_a?(Array)
                            value.map { |v| decr(v, secret) }
                          elsif value.nil?
                            nil
                          else
                            ScalarData.new(value).decrypt(secret)
                          end
        end
        new_hash
      end

      private

    end
  end
end
