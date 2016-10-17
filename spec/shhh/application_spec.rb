require 'spec_helper'

module Shhh
  module App
    RSpec.describe 'Shhh::Application' do

      context 'basic initialization' do
        let(:opts) { { generate: true, copy: true }}
        let(:application) { Shhh::Application.new(opts) }

        it 'should properly initialize' do
          expect(application).to_not be_nil
          expect(application.opts).to_not be_nil
          expect(application.opts[:generate]).to be_truthy
          expect(application.command).to be_a_kind_of(Shhh::App::Commands::GenerateKey)
        end
      end

      context 'editor' do
        let(:opts) { { help: true }}
        let(:application) { Shhh::Application.new(opts) }
        let(:existing_editor) { 'exe/shhh' }
        let(:non_existing_editor) { '/tmp/broohaha/vim' }
        it 'should return the first valid editor from the list' do
          expect(application).to_not be_nil
          expect(application).to receive(:editors_to_try).
            and_return([ non_existing_editor, existing_editor])
          expect(application.editor).to eql(existing_editor)
        end
      end
    end
  end
end
