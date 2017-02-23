require_relative 'base'

module Sym
  module App
    module Output
      class Stdout < Sym::App::Output::Base
        required_option nil

        def output_proc
          ->(argument) { printf "%s", argument }
        end
      end
    end
  end
end
