require 'active_support/inflector'
require 'hashie/mash'
require 'hashie/extensions/symbolize_keys'
require 'secrets/errors'

module Secrets
  module Encrypted

    class AbstractData

      include Secrets
      include Secrets::Encrypted

      attr_accessor :data

      def initialize(data)
        raise Secrets::Errors::UnsupportedType.new(data.class) unless self.class.supports?(data)
        self.data = data
      end

      def self.support?(*)
        false
      end

      def encrypt(secret)
        raise Errors::AbstractMethodCalled.new :encrypt
      end

      def decrypt(secret)
        raise Errors::AbstractMethodCalled.new :decrypt
      end

      def original
        raise Errors::AbstractMethodCalled.new :original
      end
    end
  end
end
