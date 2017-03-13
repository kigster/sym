require 'sym/app/commands/base_command'
require 'sym/app/keychain'
require 'sym/errors'
module Sym
  module App
    module Commands
      class KeychainAddKey < BaseCommand

        required_options [:key, :interactive],
                         :keychain
        incompatible_options %i(examples help version bash_support)
        try_after :generate_key, :encrypt, :decrypt, :password_protect_key

        def execute
          if Sym.default_key? && Sym.default_key == self.key
            raise 'Refusing to import key specified in the default key file ' + Sym.default_key_file.italic
          end
          raise Sym::Errors::NoPrivateKeyFound.new("Unable to resolve private key from argument '#{opts[:key]}'") if self.key.nil?
          add_to_keychain_if_needed(self.key)
          self.key unless opts[:quiet]
        end
      end
    end
  end
end
