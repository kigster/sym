require_relative 'command'
require 'secrets/app/keychain'
module Secrets
  module App
    module Commands
      class DeleteKeychainKey < Command
        include Secrets
        required_options   :delete_key
        def run
          Secrets::App::KeyChain.new(opts[:delete_key]).delete
        end
      end
    end
  end
end
