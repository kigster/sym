require_relative 'command'
module Shhh
  module App
    module Commands
      class ShowVersion < Command
        required_options :version
        try_after :show_help
        def execute
          "shhh (version #{Shhh::VERSION})"
        end
      end
    end
  end
end
