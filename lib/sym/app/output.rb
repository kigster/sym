# frozen_string_literal: true

require 'sym/app/output/base'
require 'sym/app/output/file'
require 'sym/app/output/stdout'
require 'sym/app/output/noop'

module Sym
  module App
    module Output
      def self.outputs
        Sym::App::Output::Base.options_to_outputs
      end
    end
  end
end
