require_relative 'command'
require 'sym/app/keychain'
module Sym
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
