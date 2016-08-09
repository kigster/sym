require 'spec_helper'
require 'digest'
module Secrets
  module App
    module Commands
      RSpec.describe GenerateKey do
        include_context :commands

        let(:argv) { %w(-gcT) }
        let(:command_class) {  GenerateKey }

        context 'new private key' do
          it 'should be generated' do
            expect(program_output.length).to eql(44)
            expect(program_output[-1]).to eql('=')
          end
        end
      end
    end
  end
end
