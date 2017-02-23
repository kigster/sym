require_relative 'output/base'
require_relative 'output/file'
require_relative 'output/noop'
require_relative 'output/stdout'

module Sym
  module App
    module Output
      def self.outputs
        Sym::App::Output::Base.options_to_outputs
      end
    end
  end
end
