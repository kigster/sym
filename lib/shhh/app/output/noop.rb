require_relative 'base'
module Shhh
  module App
    module Output
      class Noop < Shhh::App::Output::Base
        required_option :quiet

        def output_proc
          ->(*) { ; }
        end
      end
    end
  end
end
