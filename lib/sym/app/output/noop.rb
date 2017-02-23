require_relative 'base'

module Sym
  module App
    module Output
      class Noop < Sym::App::Output::Base
        required_option :quiet

        def output_proc
          ->(*) { ; }
        end
      end
    end
  end
end
