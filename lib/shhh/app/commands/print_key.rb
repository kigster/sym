require_relative 'command'
require 'shhh/app/keychain'
module Shhh
  module App
    module Commands
      class PrintKey < Command
        required_options [ :keychain, :keyfile ]

        def execute
          self.key
        end
      end
    end
  end
end
