require 'spec_helper'
require 'shhh/app'
module Shhh
  module App
    RSpec.describe 'Shhh::App::CLI' do

      context 'generate private key' do
        let(:argv) { %w(-g -v) }
        before do
          expect(cli.command.class).to receive(:create_private_key).and_return(TEST_KEY)
        end
        include_context :run_command
        it 'should output the generated private_key' do
          expect_command_to_have klass:  Commands::GenerateKey,
                                 output: [/[a-zA-Z0-9\-_=]{44}/],
                                 option: :generate,
                                 value:  true,
                                 lines:  1
        end
      end

      context 'show version' do
        let(:argv) { %w(-V -T) }
        include_context :run_command
        it 'should output the version number' do
          expect_command_to_have klass:  Commands::ShowVersion,
                                 output: ["shhh (version #{Shhh::VERSION})"],
                                 option: :version,
                                 value:  true,
                                 lines:  1
        end
      end

      context 'show examples' do
        let(:argv) { %w(-E) }
        include_context :run_command
        it 'should output the examples' do
          expect_command_to_have klass:  Commands::ShowExamples,
                                 output: [/generate a new private key/],
                                 option: :examples,
                                 value:  true
        end
      end

      context 'insufficient arguments' do
        let(:argv) { ['-k', private_key, '-v'] }
        before do
          expect(cli).to receive(:error).once
        end
        include_context :run_command
        it 'should show usage' do
          expect_command_to_have klass:  :nil?,
                                 output: [/Usage/]
        end
      end

      context 'perform encryption' do
        let(:string) { 'HelloWorld' }
        let(:argv) { "-e -s #{string} -k #{private_key} -v -T".split(' ') }
        let(:encrypted_string) { program_output }

        include_context :run_command

        it 'should output the encrypted data' do
          expect(opts[:encrypt] == true).to be_truthy
          expect(opts[:string]).to eql(string)
        end

        it 'should be able to decrypt data back' do
          expect(test_instance.decr(encrypted_string, private_key)).to eql(string)
        end
      end


      context 'as well as decryption' do
        let(:string) { 'HelloWorld' }
        let(:encrypted_string) { test_instance.encr(string, private_key) }
        let(:decrypted_string) { program_output }
        let(:argv) { "-d -s #{encrypted_string} -k #{private_key} -v".split(' ') }

        include_context :run_command

        it 'should decrypt' do
          expect(decrypted_string).to eql(string)
        end
      end


      context 'when loading key from file' do
        let(:string) { 'HelloWorld' }
        let(:encrypted_string) { test_instance.encr(string, private_key) }
        let(:decrypted_string) { program_output }
        let(:tempfile) { Tempfile.new('shhh') }
        let(:argv) { "-d -s #{encrypted_string} -K #{tempfile.path} -v -T".split(' ') }

        before do
          tempfile.write(private_key)
          tempfile.flush
        end

        include_context :run_command

        it 'should decrypt' do
          expect(decrypted_string).to eql(string)
        end

      end
    end
  end
end
