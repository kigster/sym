require 'shhh/app/output/file'
module Shhh
  module App
    module Output
      class Stdout < ::Shhh::App::Output::Base
        required_option nil
        def output_proc
          ->(argument) { puts argument }
        end
      end
    end
  end
end
