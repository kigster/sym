require 'spec_helper'

RSpec.describe 'CLI execution', :type => :aruba do
  let(:args) { ' -g ' }
  let(:command) { "bash -c 'shhh #{args}'" }

  before do
    run_simple command
  end

  let(:output) { last_command_started.stdout.chomp }

  COMMANDS = [
    { args: '-g' ,
      output: ->(example, o) { example.expect(o.size).to example.be_between(42,44) },
      desc: 'generate a key thats\' less than 44 characters long'}
  ]


  context 'running commands' do
    COMMANDS.each do |command_to_test|
      args = command_to_test[:args]
      out_proc  = command_to_test[:output]
      desc = command_to_test[:desc]
      it "command 'shhh #{args}' should #{desc}" do
        out_proc.call(self, output)
      end
    end
  end
end
