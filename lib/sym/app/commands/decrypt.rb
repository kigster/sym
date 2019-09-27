# frozen_string_literal: true

require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class Decrypt < BaseCommand
        include Sym

        required_options [:key, :interactive],
                         [:decrypt],
                         [:file, :string]

        try_after :generate_key

        def execute
          send(application.action, content, application.key)
        end
      end
    end
  end
end
