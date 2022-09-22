require 'spec_helper'
require 'sym/app'
require 'digest'
module Sym
  module App
    module Commands
      if Sym::App.osx?
        RSpec.describe PrintKey do
          let(:key_name) { 'boochen-topolski' }
          let(:command_class) { described_class }
          let(:key) { TestClass.create_private_key }

          before do
            expect(::Sym::App::KeyChain).to receive(:get).with(key_name).and_return(key)
          end

          context 'when only -k is provided' do
            let(:argv) { "-k #{key_name} --trace ".split }

            include_context 'run command'

            it 'prints the base64-encoded key itself' do
              expect(application.command).to be_a(command_class)
              expect(program_output).to eql(key)
            end
          end

          context 'when -q is provided its not printed' do
            let(:argv) { "-k #{key_name} -q --trace".split }

            include_context 'run command'

            it 'does not print anything for -q' do
              expect(program_output).to eql('')
            end
          end
        end
      end
    end
  end
end
