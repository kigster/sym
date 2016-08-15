require 'shhh/app/output/base'
require 'shhh/app/output/file'
require 'shhh/app/output/stdout'
require 'shhh/app/output/noop'

module Shhh
  module App
    module Output
      def self.outputs
        Shhh::App::Output::Base.options_to_outputs
      end
    end
  end
end

