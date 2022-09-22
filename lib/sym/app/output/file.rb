require 'sym/app/output/base'
module Sym
  module App
    module Output
      class File < ::Sym::App::Output::Base

        required_option :output

        def output_proc
          Sym::App.log :info, "writing to a file #{opts[:output]}"
          ->(data) {
            ::File.write(opts[:output], data)
          }
        end
      end
    end
  end
end
