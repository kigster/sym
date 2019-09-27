# frozen_string_literal: true

require 'sym/app/output/base'

module Sym
  module App
    module Output
      class Noop < Sym::App::Output::Base
        required_option :quiet

        def output_proc
          ->(*) {}
        end
      end
    end
  end
end
