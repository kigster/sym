require 'sym/app/commands/base_command'
require 'sym/app/keychain'
module Sym
  module App
    module Commands
      class GenerateKey < BaseCommand

        required_options :generate
        try_after :show_version

        def execute
          retries ||= 0

          the_key = create_key
          the_key = encrypt_password_if_needed(the_key)
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
