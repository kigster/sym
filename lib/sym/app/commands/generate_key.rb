require 'sym/app/commands/base_command'
require 'sym/app/keychain'
module Sym
  module App
    module Commands
      class GenerateKey < BaseCommand

        required_options :generate

        try_after :show_help

        def execute
          retries ||= 0

          the_key = create_key

          if opts[:password]
            encrypted_key, password = encrypt_with_password(the_key)
            add_password_to_the_cache(encrypted_key, password)
            the_key = encrypted_key
          end

          add_to_keychain_if_needed(the_key)
          the_key
        rescue Sym::Errors::PasswordsDontMatch, Sym::Errors::PasswordTooShort => e
          STDERR.puts e.message.bold
          retry if (retries += 1) < 3
        end
      end
    end
  end
end
