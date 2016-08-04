require 'base64'

module Secrets
  module Cipher
    module Base64
      class SecretIsNotDefinedError < ArgumentError;
      end
    end
  end
end

