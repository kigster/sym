require_relative '../errors'
module Shhh
  module Data
    class WrapperStruct < Struct.new(
      :encrypted_data,        # [Blob] Binary encrypted data (possibly compressed)
      :iv,                    # [String] IV used to encrypt the data
      :cipher_name,           # [String] Name of the cipher used
      :salt,                  # [Integer] For password-encrypted data this is the salt
      :version,               # [Integer] Version of the cipher used
      :compress               # [Boolean] indicates if compression should be applied
      )

      VERSION = 1

      attr_accessor :compressed

      def initialize(
        encrypted_data:, # [Blob] Binary encrypted data (possibly compressed)
        iv:, # [String] IV used to encrypt the data
        cipher_name:, # [String] Name of the cipher used
        salt: nil, # [Integer] For password-encrypted data this is the salt
        version: VERSION, # [Integer] Version of the cipher used
        compress: Shhh::Configuration.config.compression_enabled
      )
        super(encrypted_data, iv, cipher_name, salt, version, compress)
      end

      def config
        Shhh::Configuration.config
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


