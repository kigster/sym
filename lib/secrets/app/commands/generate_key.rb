module Secrets
  module App
    module Commands
      class GenerateKey < Command
        include Secrets

        required_options :generate
        def run
          self.class.create_private_key
        end
      end
    end
  end
end
