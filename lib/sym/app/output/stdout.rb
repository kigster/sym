# frozen_string_literal: true

require 'sym/app/output/file'
module Sym
  module App
    module Output
      class Stdout < ::Sym::App::Output::Base
        required_option nil
        def output_proc
          ->(argument) do
            stdout.printf '%s', argument
            stdout.printf "\n" if stdout.tty?
          end
        end
      end
    end
  end
end
