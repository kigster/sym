require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class ShowVersion < BaseCommand
        required_options :version
        try_after :show_examples
        def execute
          "sym (version #{Sym::VERSION})"
        end
      end
    end
  end
end
