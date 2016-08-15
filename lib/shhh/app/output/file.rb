require 'shhh/app/output/base'
module Shhh
  module App
    module Output
      class File < ::Shhh::App::Output::Base

        required_option :output


        def output_proc
          ->(data) {
            ::File.open(opts[:output], 'w') { |f| f.write(data) }
          }
        end
      end
    end
  end
end
