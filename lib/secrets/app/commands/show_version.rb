module Secrets
  module App
    module Commands
      class ShowVersion < Command
        required_options :version
        def run
          "secrets-cipher-base64 (version #{Secrets::VERSION})"
        end
      end
    end
  end
end
