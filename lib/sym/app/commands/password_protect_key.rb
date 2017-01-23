require 'sym/app/commands/base_command'

module Sym
  module App
    module Commands
      class PasswordProtectKey < BaseCommand

        required_options [:private_key, :keyfile, :keychain, :interactive],
                         :password

        try_after :generate_key, :encrypt_decrypt

        def execute
          retries ||= 0

          the_key = self.key
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
