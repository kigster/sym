require_relative 'command'
require 'secrets/app/keychain'
module Secrets
  module App
    module Commands
      class KeychainKeyDelete < Command
        required_options :keychain_del
        incompatible_options :generate
        def run
          Secrets::App::KeyChain.new(opts[:keychain_del]).delete
        end
      end
    end
  end
end
