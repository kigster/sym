require 'sym/app/commands/base_command'

module Sym
  module App
    module Commands
      class PasswordProtectKey < BaseCommand

        required_options [:key, :interactive],
                         :password

        try_after :generate_key, :encrypt, :decrypt

        def execute
          retries ||= 0

          the_key = self.key

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
