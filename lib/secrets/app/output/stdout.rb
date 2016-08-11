module Secrets
  module App
    module Output
      class Stdout < File
        def output_proc
          ->(argument) { puts argument }
        end
      end
    end
  end
end
