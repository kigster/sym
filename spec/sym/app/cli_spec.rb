require 'spec_helper'
require 'sym/app/output/base'

module Sym
  module App
    RSpec.describe 'Sym::App::CLI' do

      context 'basic initialization' do
        let(:argv) { %w(-g) }
        let(:cli) { Sym::App::CLI.new(argv) }

        it 'should properly initialize' do
          expect(cli).to_not be_nil
          expect(cli.opts).to_not be_nil
          expect(cli.opts[:generate]).to be_truthy
          expect(cli.command).to be_a_kind_of(Sym::App::Commands::GenerateKey)
        end
      end

      context 'basic initialization from SYM_ARGS' do
        let(:argv) { %w(-e -s hello -A) }
        let(:key) { 'YJOkFraX1JDuQWEbV1JpeYvwUpt0h9tbuSO4XAZ8Asc=' }
        let(:cli) { Sym::App::CLI.new(argv) }

        context '#sym_args' do
          before do
            expect_any_instance_of(Sym::App::CLI).to receive(:sym_args).and_return("-k #{key} -v -D")
          end

          it 'should properly initialize' do
            expect(cli.application).to_not be_nil
            expect(cli.application.provided_options.keys.sort).to eq %i(encrypt string key verbose debug sym_args).sort
            expect(cli.command).to be_a_kind_of(Sym::App::Commands::Encrypt)
          end
        end

        context '#opts' do
          before do
            allow(ENV).to receive(:[]).with('SYM_CACHE_TTL')
            allow(ENV).to receive(:[]).with('MEMCACHE_USERNAME')
            allow(ENV).to receive(:[]).with(Sym::Constants::ENV_ARGS_VARIABLE_NAME).and_return("-k #{key} -v -D")
          end

          let!(:opts) { cli.opts }

          context 'with -A' do
            it 'should contain flags specified in ENV variable' do
              expect(opts[:encrypt]).to be true
              expect(opts[:string]).to eq('hello')
              expect(opts[:debug]).to be true
              expect(opts[:verbose]).to be true
              expect(opts[:key]).to eq(key)
            end
          end
          context 'without -A' do
            let(:argv) { %w(-e -s hello) }
            it 'should NOT contain flags specified in ENV variable' do
              expect(opts[:encrypt]).to be true
              expect(opts[:debug]).to be false
              expect(opts[:key]).to be_nil
            end
          end
        end
      end

      context 'generate private key' do
        let(:argv) { %w(-g) }
        before do
          expect(cli).not_to be_nil
          expect(cli.command).not_to be_nil
          expect(cli.command.class).to eq(Commands::GenerateKey)
          expect(cli.command).to receive(:create_key).and_return(TEST_KEY)
        end
        include_context :run_command
        it 'should output the generated key' do
          expect_command_to_have klass:  Commands::GenerateKey,
                                 output: [/[a-zA-Z0-9\-_=]{44}/],
                                 option: :generate,
                                 value:  true,
                                 lines:  1
        end
      end

      context 'show version' do
        let(:argv) { %w(--version --trace) }
        before { allow_any_instance_of(Sym::App::CLI).to receive(:args_from_environment).and_return(nil) }
        include_context :run_command
        it 'should correctly define opts' do
          expect(cli.application.provided_options.keys.sort).to eq %i(version trace).sort
        end
        it 'should output the version number' do
          expect_command_to_have klass:  Commands::ShowVersion,
                                 output: ["sym (version #{Sym::VERSION})"],
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
        let(:argv) { %w(-e -v) }
        before do
          expect(Sym).to receive(:default_key?).and_return(false)
          expect(Sym::App).to receive(:error)
        end
        include_context :run_command
        it 'should show usage' do
          expect(cli.command).to be_nil
        end
      end

      context 'perform encryption' do
        let(:string) { 'HelloWorld' }
        let(:argv) { "-e -s #{string} -k #{key} -v --trace".split(' ') }
        let(:encrypted_string) { program_output }

        include_context :run_command

        it 'should output the encrypted data' do
          expect(opts[:encrypt] == true).to be_truthy
          expect(opts[:string]).to eql(string)
        end

        it 'should be able to decrypt data back' do
          expect(encrypted_string).to_not be_nil
          expect(test_instance.decr(encrypted_string, key)).to eql(string)
        end
      end

      #–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

      context 'perform decryption' do
        SAVE_TO_TEMPFILE = ->(content) {
          tempfile = Tempfile.new('sym');
          tempfile.instance_eval { write(content); flush }
          tempfile
        }

        RSpec.shared_context :decrypting do
          let(:string) { 'I am being encrypted' }
          let(:encrypted_string) { test_instance.encr(string, key) }
          let(:decrypted_string) { program_output }

          include_context :run_command
        end

        context 'when key is unencrypted' do

          context 'and is supplied via -k string' do
            include_context :decrypting

            let(:argv) { "-d -s #{encrypted_string} -k #{key} -v".split(' ') }

            it 'should decrypt' do
              expect(decrypted_string).to eql(string)
            end
          end

          context 'and is supplied via -k frile' do
            include_context :decrypting

            let(:argv) { "-d -s #{encrypted_string} -k #{tempfile.path} -v --trace".split(' ') }
            let!(:tempfile) { SAVE_TO_TEMPFILE.call(key) }

            it 'should decrypt' do
              expect(decrypted_string).to eql(string)
            end
          end
        end

        context 'when the key is password-protected' do
          let!(:password) { 'pIA44z!w04DS' }
          let!(:encrypted_key) { test_instance.encr_password(key, password) }
          let!(:argv) { "-d -s #{encrypted_string} -k #{tempfile.path} -v --trace".split(' ') }
          let!(:tempfile) { SAVE_TO_TEMPFILE.call(encrypted_key) }
          let!(:input_handler) { Sym::App::Input::Handler.new }

          before do
            expect(input_handler).to receive(:ask).exactly(attempts).times.and_return(decryption_password)
            application.input_handler = input_handler
          end

          include_context :decrypting

          context 'and the password is correct' do
            let(:decryption_password) { password }
            let(:attempts) { 1 }
            it 'should decrypt' do
              expect(decrypted_string).to eql(string)
              expect(File.read(tempfile.path)).to eql(encrypted_key)
              expect(File.read(tempfile.path)).not_to eql(key)
              expect(decrypted_string).to eql(string)
            end
          end

          context 'and has a wrong password' do
            let(:decryption_password) { 'barhoohaaa' }
            let(:attempts) { 3 }
            let(:run_cli) { false }

            it 'should decrypt' do
              expect(File.read(tempfile.path)).to eql(encrypted_key)
              expect(File.read(tempfile.path)).not_to eql(key)
              expect(input_handler).to receive(:puts).and_return(nil).exactly(attempts).times
              expect(cli).to receive(:error).
                with(reason:    'invalid password provided for the private key',
                     exception: Sym::Errors::InvalidPasswordProvidedForThePrivateKey)
              cli.execute
            end
          end
        end
      end
    end
  end
end
