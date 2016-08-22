require 'spec_helper'

module Shhh
  module App
    RSpec.describe 'Shhh::Application' do

      context 'basic initialization' do
        let(:opts) { { :generate => true, :copy => true }}
        let(:application) { Shhh::Application.new(opts) }

        it 'should properly initialize' do
          expect(application).to_not be_nil
          expect(application.opts).to_not be_nil
          expect(application.opts[:generate]).to be_truthy
          expect(application.command).to be_a_kind_of(Shhh::App::Commands::GenerateKey)
        end
      end
    end
  end
end
