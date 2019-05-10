require 'spec_helper'
require 'digest'
module Sym
  module App
    module Commands
      RSpec.describe GenerateKey do

        context 'new private key' do

          include_context :run_command

          let(:argv) { %w(-g -T) }
          it 'should be generated' do
            expect_command_to_have klass:          GenerateKey,
                                   output:         [%r([a-zA-Z0-9\-_=]{44,45})],
                                   option:         :generate,
                                   value:          true,
                                   program_output: program_output_lines

          end

          let(:key) { program_output }
          it_behaves_like 'a private key'
        end
      end
    end
  end
end
