require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class ShowHelp < BaseCommand

        required_options :help, ->(opts) { opts.to_hash.keys.all? { |k| !opts[k] } }

        def execute
          opts.to_s(prefix: ' ' * 2)
        end
      end
    end
  end
end
