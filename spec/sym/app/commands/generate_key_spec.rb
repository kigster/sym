require 'spec_helper'
require 'digest'
module Sym
  module App
    module Commands
      RSpec.describe GenerateKey do

        context 'new private key' do

          let(:argv) { %w(-g) }

          include_context :commands

          it 'should be generated' do
            expect_command_to_have klass:          GenerateKey,
                                   output:         [%r([a-zA-Z0-9\-_=]{44,45})],
                                   option:         :generate,
                                   value:          true,
                                   program_output: console.lines

          end

          context 'the key' do
            let(:key) { program_output }

            it_behaves_like 'a private key'
          end
        end
      end
    end
  end
end
