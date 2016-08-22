require 'shhh/app/output/base'
require 'spec_helper'
require 'singleton'

module Shhh
  module App
    RSpec.describe Shhh::App::Password::Cache do
      let(:opts) { { keyfile: true, edit: true } }
      let(:args) { Args.new(opts) }

      # TODO: write password cache
      it 'should be able to cache password' do

      end
    end
  end
end
