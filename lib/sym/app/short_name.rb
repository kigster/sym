# frozen_string_literal: true

require 'active_support/inflector'
module Sym
  module App
    module ShortName
      def short_name
        name.split(/::/)[-1].underscore.to_sym
      end
    end
  end
end
