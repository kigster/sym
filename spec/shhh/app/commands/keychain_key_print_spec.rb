require 'spec_helper'
require 'digest'
module Shhh
  module App
    module Commands
      if Shhh::App.is_osx?
        RSpec.describe PrintKey do


          let(:key_name) { 'boochen-topolski' }
          let(:argv) { "-x #{key_name} -v -T ".split(' ') }
          let(:command_class) { PrintKey }
          let(:keychain) { Shhh::App::KeyChain.new(key_name) }
          let(:private_key) { TestClass.create_private_key }

          before do
            keychain.add(private_key)
            expect(keychain.find).to eql(private_key)
          end


          context 'when only -x is provided' do
            include_context :run_command
            it 'should print the base64-encoded key itself' do
              expect(application.command).to be_a_kind_of(command_class)
              expect(program_output).to eql(private_key)
            end
          end

          context 'when -q is provided its not printed' do
            let(:argv) { "-x #{key_name} -q -T".split(' ') }
            include_context :run_command
            it 'should not print anything for -q' do
              expect(program_output).to eql('')
            end
          end
        end
      end
    end
  end
end
