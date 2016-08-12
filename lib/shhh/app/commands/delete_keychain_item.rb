require_relative 'command'
require 'shhh/app/keychain'
module Shhh
  module App
    module Commands
      class DeleteKeychainItem < Command

        required_options :keychain_del
        try_after :generate_key, :open_editor, :encrypt_decrypt

        def run
          Shhh::App::KeyChain.new(opts[:keychain_del]).delete
        end
      end
    end
  end
end
