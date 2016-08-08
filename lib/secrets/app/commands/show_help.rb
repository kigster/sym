module Secrets
  module App
    module Commands
      class ShowHelp < Command
        required_options :help, ->(opts) { opts.keys.all? { |k| !opts[k] } }
        def run
          opts.to_s
        end
      end
    end
  end
end
