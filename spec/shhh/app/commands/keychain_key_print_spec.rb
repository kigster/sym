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
          let(:k) { PrintKey.create_private_key }
          before do
            keychain.add(k)
          end

          include_context :run_command

          context 'when only -x is provided' do
            it 'should print the base64-encoded key itself' do
              expect(program_output).to eql(k)
            end
          end
        end
      end
    end
  end
end
