require 'sym/app/commands/base_command'

module Sym
  module App
    module Commands
      class PasswordProtectKey < BaseCommand

        required_options %i(key interactive), :password
        incompatible_options %i(examples help version bash_support)
        try_after :generate_key, :encrypt, :decrypt

        def execute
          retries ||= 0
          raise Sym::Errors::NoPrivateKeyFound.new("Unable to resolve private key from argument '#{opts[:key]}'") if self.key.nil?

          the_key = self.key

          if opts[:password]
             encrypted_key = encrypt_with_password(the_key)
             add_password_to_the_cache(encrypted_key)
             the_key = encrypted_key.key
           end

          add_to_keychain_if_needed(the_key)

          the_key
        rescue Sym::Errors::PasswordsDontMatch, Sym::Errors::PasswordTooShort => e
          stderr.puts e.message.bold
          retry if (retries += 1) < 3
        end

      end
    end
  end
end
