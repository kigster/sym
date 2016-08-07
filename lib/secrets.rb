require 'require_dir'
require 'colored2'

module Secrets
  extend RequireDir
  init(__FILE__)
end

Secrets.dir 'secrets/extensions'

# This is the main module that can either be used directly, via it's
# convenient Facåde API:
#
# ```ruby
# encrypted_hash = Secrets::Encrypt.hash({'name' => :unknown}, Secrets.secret)
# decrypted_hash = Secrets::Decrypt.hash(encrypted_hash, Secrets.secret)
# ````
# or via including it and using +#encr+ and +#decr+ instance methods, as well as
# +#secret+ and +#create_secret+ class methods.
#
# ```ruby
# require 'secrets'
# class TestClass
#   include Secrets
#   def sensitive_value=(value)
#     @sensitive_value = encr(value, self.class.secret)
#   end
#   def sensitive_value
#     decr(@sensitive_value, self.class.secret)
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
            @secret = self.create_secret
          end
          @secret
        end
      end
    end
  end
end

Secrets.dir 'secrets'
Secrets.dir 'secrets/encrypted'

module Secrets
  # Public Facåde for this library
  module Encrypt
    def self.hash(hash, secret)
      Secrets::Encrypted::HashData.new(hash).encrypt(secret)
    end

    def self.scalar(scalar, secret)
      Secrets::Encrypted::ScalarData.new(scalar).encrypt(secret)
    end
  end
  module Decrypt
    def self.hash(hash, secret)
      Secrets::Encrypted::HashData.new(hash).decrypt(secret)
    end

    def self.scalar(scalar, secret)
      Secrets::Encrypted::ScalarData.new(scalar).decrypt(secret)
    end
  end

  class << self
    # It can also be extended with new data types as follows:
    # ```ruby
    #   Secrets.add_scalar_type type:, string_to_type_proc, identifier:
    # ````
    #
    # For example:
    #
    # `Secrets.add_scalar_type type: String, string_to_type_proc: ->(string) { string }, id: 's'`
    #
    def add_scalar_type(id:, type:, string_to_type_proc:)
      Secrets::Encrypted::ScalarData::ScalarTypeMapping.
        add_type(
          id:                  id,
          type:                type,
          string_to_type_proc: string_to_type_proc
        )
    end
  end

  add_scalar_type id: 's', type: String, string_to_type_proc: ->(string) { string }
  add_scalar_type id: 'i', type: Integer, string_to_type_proc: ->(string) { string.to_i }
  add_scalar_type id: 'f', type: Float, string_to_type_proc: ->(string) { string.to_f }
  add_scalar_type id: 'm', type: Fixnum, string_to_type_proc: ->(string) { string.to_i }
  add_scalar_type id: 'r', type: Rational, string_to_type_proc: ->(string) { string.to_r }
  add_scalar_type id: 'c', type: Complex, string_to_type_proc: ->(string) { string.to_c }
  add_scalar_type id: 'b', type: Symbol, string_to_type_proc: ->(string) { string.to_sym }
  add_scalar_type id: 'F', type: FalseClass, string_to_type_proc: ->(*) { false }
  add_scalar_type id: 'T', type: TrueClass, string_to_type_proc: ->(*) { true }
end


