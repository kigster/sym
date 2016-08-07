require 'require_dir'
require 'colored2'

module Secrets
  extend RequireDir
  init(__FILE__)
end

Secrets.dir 'secrets/extensions'
#
# Include this class and use +#encr+ and +#decr+ instance methods to perform
# encryption and decryption of object of any type (as long as it can be Marshalled to a string).
#
# Use class method +#secret+ class method to assign, or generate and store
# a class-evel secret, or use class method +#create_private_key+ to just purely generate
# a new encryption secret when needed.
#
# ```ruby
# require 'secrets'
# class TestClass
#   include Secrets
#   def sensitive_value=(value)
#     @sensitive_value = encr(value, self.class.private_key)
#   end
#   def sensitive_value
#     decr(@sensitive_value, self.class.private_key)
#   end
# end
# ```
module Secrets

  def self.included(klass)
    klass.instance_eval do
      include ::Secrets::Extensions::InstanceMethods
      extend ::Secrets::Extensions::ClassMethods
      class << self
        def secret(value = nil)
          if value
            @secret = value
          elsif @secret
            @secret
          else
            @secret = self.create_private_key
          end
          @secret
        end
      end
    end
  end
end

Secrets.dir 'secrets'
Secrets.dir 'secrets/encrypted'


