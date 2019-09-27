require 'sym/app/commands/base_command'
require 'sym/app/keychain'
require 'sym/app/encrypted_key_struct'

module Sym
  module App
    module Commands
      class GenerateKey < BaseCommand

        required_options :generate

        try_after :show_help

        def execute
          retries ||= 0

          new_key = create_key

          if opts[:password]
            encrypted_key_struct = encrypt_with_password(new_key)
            new_key = encrypted_key_struct.key_encrypted
            add_password_to_the_cache(new_key)
          end

          add_to_keychain_if_needed(new_key)

          new_key

        rescue Sym::Errors::PasswordsDontMatch, Sym::Errors::PasswordTooShort => e
          stderr.puts e.message.bold
          retry if (retries += 1) < 3
        end
      end
    end
  end
end
