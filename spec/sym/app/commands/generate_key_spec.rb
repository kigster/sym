require 'spec_helper'
require 'digest'
module Sym
  module App
    module Commands
      RSpec.describe GenerateKey do

        context 'new private key' do

          include_context 'run command'

          let(:argv) { %w(-g -T) }
          let(:key) { program_output }
          let(:key) { program_output }

          it 'is generated' do
            expect_command_to_have klass: described_class,
                                   output: [ %r([a-zA-Z0-9\-_=]{44,45}) ],
                                   option: :generate,
                                   value: true
          end


          it_behaves_like 'a private key'
        end
      end
    end
  end
end
