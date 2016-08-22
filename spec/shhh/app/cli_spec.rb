require 'spec_helper'
require 'shhh/app/output/base'

module Shhh
  module App
    RSpec.describe 'Shhh::App::CLI' do

      context 'basic initialization' do
        let(:argv) { %w(-gc) }
        let(:cli) { Shhh::App::CLI.new(argv) }

        it 'should properly initialize' do
          expect(cli).to_not be_nil
          expect(cli.opts).to_not be_nil
          expect(cli.opts[:generate]).to be_truthy
          expect(cli.command).to be_a_kind_of(Shhh::App::Commands::GenerateKey)
        end
      end

      context 'generate private key' do
        let(:argv) { %w(-g -v) }
        before do
          expect(cli).not_to be_nil
          expect(cli.command).not_to be_nil
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
          expect(Shhh::App).to receive(:error)
        end
        include_context :run_command
        it 'should show usage' do
          expect(cli.command).to be_nil
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


      #–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

      context 'perform decryption' do


        SAVE_TO_TEMPFILE = ->(content) {
          tempfile = Tempfile.new('shhh');
          tempfile.instance_eval { write(content); flush }
          tempfile
        }

        RSpec.shared_context :decrypting do
          let(:string) { 'I am being encrypted' }
          let(:encrypted_string) { test_instance.encr(string, private_key) }
          let(:decrypted_string) { program_output }

          include_context :run_command
        end

        context 'when key is unencrypted' do

          context 'and is supplied via -k string' do
            include_context :decrypting
            let(:argv) { "-d -s #{encrypted_string} -k #{private_key} -v".split(' ') }

            it 'should decrypt' do
              expect(decrypted_string).to eql(string)
            end
          end

          context 'and is supplied via -K file' do
            let(:argv) { "-d -s #{encrypted_string} -K #{tempfile.path} -v -T".split(' ') }
            let!(:tempfile) { SAVE_TO_TEMPFILE.call(private_key) }

            include_context :decrypting
            it 'should decrypt' do
              expect(decrypted_string).to eql(string)
            end
          end
        end

        context 'when the key is password-protected' do
          let(:password) { 'pIA44z!w04DS' }
          let(:encrypted_key) { test_instance.encr_password(private_key, password) }
          let(:argv) { "-d -s #{encrypted_string} -K #{tempfile.path} -v -T".split(' ') }
          let(:tempfile) { SAVE_TO_TEMPFILE.call(encrypted_key) }
          let(:input_handler) { Shhh::App::Input::Handler.new }
          before do
            expect(input_handler).to receive(:ask).exactly(attempts).times.and_return(decryption_password)
            application.input_handler = input_handler
            application.send(:initialize_key_handler)
          end

          include_context :decrypting

          context 'and the password is correct' do
            let(:decryption_password) { password }
            let(:attempts) { 1 }
            it 'should decrypt' do
              expect(decrypted_string).to eql(string)
              expect(File.read(tempfile.path)).to eql(encrypted_key)
              expect(File.read(tempfile.path)).not_to eql(private_key)
              expect(decrypted_string).to eql(string)
            end
          end

          context 'and has a wrong password' do
            let(:decryption_password) { 'boooadfdsf' }
            let(:attempts) { 3 }
            let(:run_cli) { false }

            it 'should decrypt' do
              expect(File.read(tempfile.path)).to eql(encrypted_key)
              expect(File.read(tempfile.path)).not_to eql(private_key)
              expect(input_handler).to receive(:puts).and_return(nil).exactly(attempts).times
              expect(cli).to receive(:error).
                with(type:    'InvalidPasswordPrivateKey',
                     details: 'Invalid password.'
                )

              cli.execute
            end
          end
        end
      end
    end
  end
end
