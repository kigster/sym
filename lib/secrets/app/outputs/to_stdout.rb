module Secrets
  module App
    module Outputs
      class ToStdout < ToFile
        def output_proc
          ->(argument) { puts argument }
        end
      end
    end
  end
end
