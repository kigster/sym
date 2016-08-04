require 'base64'
require_relative '../encoder'
require_relative '../decoder'
module Secrets
  module Cipher
    module Base64
      module Extensions
        module ClassMethods
          def create_secret
            ::Base64.encode64(Secrets::Cipher::Base64::Helper::CIPHER.call.random_key)
          end
        end
      end
    end
  end
end
