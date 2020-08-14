require 'sym/errors'
module Sym
  module Data
    class WrapperStruct < Struct.new(
      # [Blob] Binary encrypted data (possibly compressed)s
      :encrypted_data,
      # [String] IV used to encrypt the datas
      :iv,
      # [String] Name of the cipher used
      :cipher_name,
      # [Integer] For password-encrypted data this is the salt
      :salt,
      # [Integer] Version of the cipher used
      :version,
      # [Boolean] indicates if compression should be applied
      :compress
    )

      define_singleton_method(:new, Class.method(:new))

      VERSION = 1

      attr_accessor :compressed

      def initialize(
        encrypted_data:,
        iv:,
        cipher_name:,
        salt: nil,
        version: VERSION,
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


