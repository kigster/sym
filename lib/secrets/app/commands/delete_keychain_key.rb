require_relative 'command'
require 'secrets/app/keychain'
module Secrets
  module App
    module Commands
      class DeleteKeychainKey < Command
        include Secrets
        required_options   :keychain_del
        def run
          Secrets::App::KeyChain.new(opts[:keychain_del]).delete
        end
      end
    end
  end
end
