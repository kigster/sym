require 'sym/errors'
module Sym
  module Data
    class WrapperStruct < Struct.new(
      :encrypted_data,        # [Blob] Binary encrypted data (possibly compressed)
      :iv,                    # [String] IV used to encrypt the data
      :cipher_name,           # [String] Name of the cipher used
      :salt,                  # [Integer] For password-encrypted data this is the salt
      :version,               # [Integer] Version of the cipher used
      :compress               # [Boolean] indicates if compression should be applied
      )
      define_singleton_method(:new, Class.method(:new))

      VERSION = 1

      attr_accessor :compressed

      def initialize(
        encrypted_data:, # [Blob] Binary encrypted data (possibly compressed)
        iv:, # [String] IV used to encrypt the data
        cipher_name:, # [String] Name of the cipher used
        salt: nil, # [Integer] For password-encrypted data this is the salt
        version: VERSION, # [Integer] Version of the cipher used
        compress: Sym::Configuration.config.compression_enabled
      )
        super(encrypted_data, iv, cipher_name, salt, version, compress)
      end

      def config
        Sym::Configuration.config
      end

      def serialize
        Marshal.dump(self)
      end

      def self.deserialize(data)
        Marshal.load(data)
      end
    end
  end
end


