require 'sym/app/output/file'
module Sym
  module App
    module Output
      class Stdout < ::Sym::App::Output::Base
        required_option nil
        def output_proc
          ->(argument) { puts argument }
        end
      end
    end
  end
end
