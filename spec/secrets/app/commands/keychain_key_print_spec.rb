require 'spec_helper'
require 'digest'
module Secrets
  module App
    module Commands
      RSpec.describe KeychainKeyPrint do
        let(:key_name) { 'boochen-topolski' }
        let(:argv) { "-x #{key_name} -v -T ".split(' ') }
        let(:command_class) { KeychainKeyPrint }
        let(:keychain) { Secrets::App::KeyChain.new(key_name) }
        let(:k) { KeychainKeyPrint.create_private_key }
        before do
          keychain.add(k)
        end

         include_context :commands

        after do
          keychain.delete rescue nil
        end
        context 'no changes' do
          it 'should detect no changes' do
            expect(program_output).to be(k)
          end
        end
      end
    end
  end
end
