require 'sym/app/commands/base_command'
require 'sym/app/keychain'
module Sym
  module App
    module Commands
      class KeychainAddKey < BaseCommand

        required_options [:private_key, :keyfile, :interactive],
                         :keychain

        try_after :generate_key, :encrypt, :decrypt, :password_protect_key

        def execute
          add_to_keychain_if_needed(self.key)
        end
      end
    end
  end
end
