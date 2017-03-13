require 'sym/app/output/file'
module Sym
  module App
    module Output
      class Stdout < ::Sym::App::Output::Base
        required_option nil
        def output_proc
          ->(argument) do
            self.stdout.printf '%s', argument
            self.stdout.printf "\n" if self.stdout.tty?
          end
        end
      end
    end
  end
end
