require 'spec_helper'

RSpec.describe 'CLI execution', :type => :aruba do

  context 'using Aruba framework' do

    let(:args) { ' -g ' }
    let(:command) { "bash -c 'sym #{args}'" }
    let(:output) { last_command_started.stdout.chomp }

    before do
      run_simple command
    end

    CommandSpec = Struct.new(:args, :desc, :proc)


    COMMANDS_TO_TEST = [
      CommandSpec.new('-g',
                      'generate a key that\'s less than 44 characters long',
                      ->(e, o) { e.expect(o.size).to e.be_between(42, 44) })
    ]

    context 'while running commands' do
      let(:output) { last_command_started.stdout.chomp }
      COMMANDS_TO_TEST.each do |cmd|
        it "command 'sym #{cmd.args}' should #{cmd.desc}" do
          cmd.proc.call(self, output)
        end
      end
    end
  end
end
