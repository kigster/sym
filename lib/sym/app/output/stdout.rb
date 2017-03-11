require 'sym/app/output/file'
module Sym
  module App
    module Output
      class Stdout < ::Sym::App::Output::Base
        required_option nil
        def output_proc
          ->(argument) do
            printf '%s', argument
            printf "\n" if STDOUT.tty?
          end
        end
      end
    end
  end
end
