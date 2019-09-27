# frozen_string_literal: true

require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class ShowVersion < BaseCommand
        required_options :version
        try_after :show_help
        def execute
          "sym (version #{Sym::VERSION})"
        end
      end
    end
  end
end
