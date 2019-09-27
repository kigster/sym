# frozen_string_literal: true

require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class ShowHelp < BaseCommand
        required_options :help, ->(opts) { opts.keys.all? { |k| !opts[k] } }

        def execute
          opts_slop.to_s(prefix: ' ' * 2)
        end
      end
    end
  end
end
