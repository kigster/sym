require_relative 'command'
require 'sym/app/keychain'
module Sym
  module App
    module Commands
      class PrintKey < Command
        required_options [ :keychain, :keyfile ]

        try_after :generate_key, :encrypt_decrypt, :password_protect_key, :keychain_add_key

        def execute
          self.key
        end
      end
    end
  end
end
