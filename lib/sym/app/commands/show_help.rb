require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class ShowHelp < BaseCommand

        required_options [ :help ]

        def execute
          opts.to_s(prefix: ' ' * 2)
        end
      end
    end
  end
end
