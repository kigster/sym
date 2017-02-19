require 'sym/app/commands/base_command'
require 'sym/app/keychain'
module Sym
  module App
    module Commands
      class PrintKey < BaseCommand
        required_options [ :keychain, :keyfile ]

        try_after :encrypt, :decrypt, :password_protect_key, :keychain_add_key, :show_help, :show_examples

        def execute
          self.key
        end
      end
    end
  end
end
