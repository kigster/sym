module Sym
  module App
    EncryptedKeyStruct = Struct.new(:encrypted_key, :password, :key) do
      def initialize(encrypted_key: nil,
                     password: nil,
                     key: nil)
        super(encrypted_key, password, key)
      end
    end
  end
end
