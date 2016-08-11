require_relative 'command'
require 'secrets/app/keychain'
module Secrets
  module App
    module Commands
      class KeychainKeyPrint < Command
        include Secrets
        required_options :keychain
        incompatible_options :generate

        def run
          cli.key
        end
      end
    end
  end
end
