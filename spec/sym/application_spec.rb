require 'spec_helper'

module Sym
  module App
    RSpec.describe 'Sym::Application' do

      context 'basic initialization' do
        let(:opts) { { generate: true }}
        let(:application) { Sym::Application.new(opts) }

        it 'should properly initialize' do
          expect(application).to_not be_nil
          expect(application.opts).to_not be_nil
          expect(application.opts[:generate]).to be_truthy
          expect(application.command).to be_a_kind_of(Sym::App::Commands::GenerateKey)
        end
      end

      context 'editor' do
        let(:opts) { { help: true }}
        let(:application) { Sym::Application.new(opts) }
        let(:existing_editor) { 'exe/sym' }
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
