require 'require_dir'
require 'colored2'

require_relative 'base64/extensions/class_methods'
require_relative 'base64/extensions/instance_methods'

module Secrets
  module Cipher
    module Base64
      extend RequireDir
      init(__FILE__)

      NEWLINE_SEP= '㎏'
      FIELD_SEP= '%'

      def self.included(klazz)
        klazz.instance_eval do
          include ::Secrets::Cipher::Base64::Extensions::InstanceMethods
          extend ::Secrets::Cipher::Base64::Extensions::ClassMethods

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
        include ::Secrets::Cipher::Base64::Extensions::ClassMethods
      end
      include ::Secrets::Cipher::Base64::Extensions::InstanceMethods
    end
  end
end

Secrets::Cipher::Base64.dir_r 'base64'

