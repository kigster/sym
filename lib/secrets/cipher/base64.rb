require 'require_dir'
require_relative 'base64/class_extensions'

module Secrets
  module Cipher
    module Base64
      extend RequireDir
      init(__FILE__)

      def self.included(klazz)
        klazz.instance_eval do
          include ::Secrets::Cipher::Base64::InstanceMethods
          extend ::Secrets::Cipher::Base64::ClassMethods

          class << self
            def secret(value = nil)
              @secret = value if value
              @secret
            end
          end
        end

      end

      class << self
        attr_accessor :secret
        self.include(InstanceMethods)
      end

    end
  end
end

Secrets::Cipher::Base64.dir 'base64'

