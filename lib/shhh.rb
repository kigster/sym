require 'require_dir'
require 'colored2'
require 'zlib'

require_relative 'shhh/configuration'

Shhh::Configuration.configure do |config|
  config.password_cipher = 'AES-128-CBC'
  config.data_cipher = 'AES-256-CBC'
  config.private_key_cipher = config.data_cipher
  config.compression_enabled = true
  config.compression_level = Zlib::BEST_COMPRESSION
end

#
# _Include_ +Shhh+ in your class to enable functionality of this library.
#
# Once included, you would normally use +#encr+ and +#decr+ instance methods to perform
# encryption and decryption of object of any type using a symmetric key encryption.
#
# You could also use +#encr_password+ and +#decr_password+ if you prefer to encrypt
# with a password instead. The encryption key is generated from the password in that
# case.
#
# Create a new key with +#create_private_key+ class method, which returns a new key every
# time it's called, or with +#private_key+ class method, which either assigns, or creates
# and caches the private key at a class level.
#
# ```ruby
# require 'shhh'
# class TestClass
#   include Shhh
#   private_key ENV['PRIVATE_KEY']
#
#   def sensitive_value=(value)
#     @sensitive_value = encr(value, self.class.private_key)
#   end
#
#   def sensitive_value
#     decr(@sensitive_value, self.class.private_key)
#   end
# end
# ```
module Shhh
  extend RequireDir
  init(__FILE__)
end

Shhh.dir 'shhh/extensions'

module Shhh
  def self.included(klass)
    klass.instance_eval do
      include ::Shhh::Extensions::InstanceMethods
      extend ::Shhh::Extensions::ClassMethods
      class << self
        def private_key(value = nil)
          if value
            @private_key= value
          elsif @private_key
            @private_key
          else
            @private_key= self.create_private_key
          end
          @private_key
        end
      end
    end
  end
end

Shhh.dir 'shhh'
Shhh.dir 'shhh/app/commands'
