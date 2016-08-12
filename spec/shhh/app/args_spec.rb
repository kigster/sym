require 'spec_helper'
require 'singleton'

module Shhh
  module App
    RSpec.describe Shhh::App::Args do
      let(:opts) { { keyfile: true, edit: true } }
      let(:args) { Args.new(opts) }

      %i(mode key).each do |type|
        context type.to_s do
          it "responds to #{type}? method" do
            expect(args.send(:"#{type}?")).to be_truthy
          end
        end
      end
    end
  end
end
