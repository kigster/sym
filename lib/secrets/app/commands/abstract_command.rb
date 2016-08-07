module Secrets
  module App
    module Commands
      class AbstractCommand
        def run
          raise Secrets::Errors::AbstractMethodCalled.new(:run)
        end
      end
    end
  end
end
