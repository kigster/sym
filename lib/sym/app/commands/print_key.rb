# frozen_string_literal: true

require 'sym/app/commands/base_command'
require 'sym/app/keychain'
require 'sym/errors'
module Sym
  module App
    module Commands
      class PrintKey < BaseCommand
        required_options %i(keychain key)
        incompatible_options %i(examples help version bash_support)
        try_after :show_examples, :generate_key, :encrypt, :decrypt, :password_protect_key, :keychain_add_key

        def execute
          raise Sym::Errors::NoPrivateKeyFound, "Unable to resolve private key from argument '#{opts[:key]}'" if key.nil?

          key
        end
      end
    end
  end
end
