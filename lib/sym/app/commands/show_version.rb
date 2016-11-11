require_relative 'command'
module Sym
  module App
    module Commands
      class ShowVersion < Command
        required_options :version
        try_after :show_help
        def execute
          "sym (version #{Sym::VERSION})"
        end
      end
    end
  end
end
