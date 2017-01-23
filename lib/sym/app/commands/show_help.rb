require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class ShowHelp < BaseCommand

        required_options :help, ->(opts) { opts.to_hash.keys.all? { |k| !opts[k] } }
        try_after :generate_key, :open_editor, :encrypt_decrypt

        def execute
          opts.to_s(prefix: ' ' * 2)
        end
      end
    end
  end
end
