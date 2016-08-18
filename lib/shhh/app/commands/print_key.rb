require_relative 'command'
require 'shhh/app/keychain'
module Shhh
  module App
    module Commands
      class PrintKey < Command
        include Shhh
        required_options [ :keychain, :keyfile ]

        try_after :show_examples
        def run
          cli.key
        end
      end
    end
  end
end
