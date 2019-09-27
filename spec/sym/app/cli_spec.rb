# frozen_string_literal: true

require 'spec_helper'
require 'sym/app/output/base'

RSpec.describe Sym::App::CLI do
  before do
    allow(ENV).to receive(:[]).and_return(nil)
  end

  describe '-A: using SYM_ARGS' do
    shared_examples :cli_expectations do
      include_examples :cli

      before do
        cli.env_args = []
        allow_any_instance_of(described_class).to receive(:fetch_env_args).and_return(sym_args)
        allow(cli).to receive(:exit_program!).and_return(nil)
      end
    end

    context '#sym_args' do
      let(:argv) { %w(-e -s hello -A) }
      let(:sym_args) { "-ck #{TEST_KEY} -v -D" }
      let(:env_args) { sym_args.split(/\s+/) }
      let(:expected_options) { %i(encrypt string key debug verbose cache_passwords).sort }

      include_examples :cli_expectations

      context 'cli' do
        subject { cli }
        its(:fetch_env_args) { should eq sym_args }
        its(:argv) { should eq (argv + env_args) }
      end

      context 'application' do
        subject { cli.application }

        it { should_not be_nil }
        its('provided_options.keys.sort') { should eq expected_options }
        its(:command) { should be_a_kind_of(Sym::App::Commands::Encrypt) }
      end
    end

    context '#opts' do
      let(:argv) { %w(-e -s hello -A) }
      let(:sym_args) { "-c -k #{key} -v -D" }
      let(:env_args) { sym_args.split(/\s+/) }

      include_examples :cli_expectations

      subject { cli }

      context 'with -A' do
        its(:fetch_env_args) { should eq sym_args }
        its(:env_args) { should include %w(-c -k -D) }
        its('opts.to_hash.size') { should eq 26 }
        its('opts.to_hash.keys') { should include %i(encrypt string cache_passwords verbose debug) }

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
        its(:env_args) { should be_nil }
        let(:opts) { cli.opts.to_hash }

        it 'should NOT contain flags specified in ENV variable' do
          expect(opts[:encrypt]).to be true
          expect(opts[:debug]).to be false
          expect(opts[:key]).to be_nil
        end
      end
    end
  end

  context '-g: generate a new private key' do
    let(:argv) { %w(-g) }

    subject { cli }

    it { should_not be_nil }
    its(:command) { should_not be_nil }
    its('command.class') { should eq Sym::App::Commands::GenerateKey }

    before do
      expect(cli.command).to receive(:create_key).and_return(TEST_KEY)
    end

    include_context :run_command

    it 'should output the generated key' do
      expect_command_to_have klass: Sym::App::Commands::GenerateKey,
                             output: [/[a-zA-Z0-9\-_=]{44}/],
                             option: :generate,
                             value: true,
                             lines: 1,
                             program_output: program_output_lines
    end
  end

  context '--version: show version' do
    let(:argv) { %w(--version --trace) }

    before { allow_any_instance_of(described_class).to receive(:args_from_environment).and_return(nil) }

    include_context :run_command

    it 'should correctly define opts' do
      expect(cli.application.provided_options.keys.sort).to eq %i(version trace).sort
    end

    it 'should output the version number' do
      expect_command_to_have klass: Sym::App::Commands::ShowVersion,
                             output: ["sym (version #{Sym::VERSION})"],
                             option: :version,
                             value: true,
                             lines: 1,
                             program_output: program_output_lines
    end
  end

  context '-E: show examples' do
    let(:argv) { %w(-E) }

    include_context :run_command

    it 'should output the examples' do
      expect_command_to_have klass: Sym::App::Commands::ShowExamples,
                             output: [/generate a new private key/],
                             option: :examples,
                             value: true,
                             program_output: program_output_lines
    end
  end
  #
  # describe 'error conditions' do
  #   context 'insufficient arguments' do
  #     let(:argv) { %w(-e -v) }
  #
  #     before do
  #       expect(Sym).to receive(:default_key?).and_return(false)
  #       expect(Sym::App).to receive(:error)
  #     end
  #
  #     include_context :run_command
  #
  #     it 'should show usage' do
  #       expect(cli.command).to be_nil
  #     end
  #   end
  # end
  #
  # describe 'encryption and decryption' do
  #   include_context :encryption
  #
  #   context 'encrypt' do
  #     let(:string) { 'HelloWorld' }
  #     let(:argv) { "-e -s #{string} -k #{key}".split(' ') }
  #
  #     include_context :run_command
  #
  #     let(:encrypted_string) { program_output }
  #
  #     it 'should output the encrypted data' do
  #       expect(opts[:encrypt]).to be(true)
  #       expect(opts[:string]).to eql(string)
  #     end
  #
  #     it 'should be able to decrypt data back' do
  #       expect(encrypted_string).to_not be_nil
  #       expect(test_instance.decr(encrypted_string, key)).to eql(string)
  #     end
  #   end
  #
  #   context 'decrypt' do
  #     let(:write_to_tempfile_proc) do
  #       ->(content) {
  #         tempfile = Tempfile.new('sym')
  #         tempfile.instance_eval { write(content); flush }
  #         tempfile
  #       }
  #     end
  #
  #     let(:string) { 'I am being encrypted' }
  #     let(:encrypted_string) { test_instance.encr(string, key) }
  #     subject(:decrypted_string) { program_output }
  #
  #     context 'when key is unencrypted' do
  #       context 'and is supplied via -k string' do
  #         let(:argv) { "-d -s #{encrypted_string} -k #{key} -v".split(' ') }
  #
  #         include_context :run_command
  #
  #         it { is_expected.to eq string }
  #       end
  #
  #       context 'and is supplied via -k file-path' do
  #         let(:tempfile) { write_to_tempfile_proc[key] }
  #         let(:argv) { "-d -s #{encrypted_string} -k #{tempfile.path} -v --trace".split(' ') }
  #
  #         include_context :run_command
  #
  #         it { is_expected.to eq string }
  #       end
  #     end
  #
  #     context 'when the key is password-protected' do
  #
  #       let(:password) { 'pIA44z!w04DS' }
  #       let(:input_handler) { Sym::App::Input::Handler.new }
  #
  #       let(:tempfile) { write_to_tempfile_proc[encrypted_key] }
  #       let(:tempfile_key) { File.read(tempfile.path) }
  #
  #       let(:encrypted_key) { test_instance.encr_password(key, password) }
  #       let(:argv) { "-d -s #{encrypted_string} -k #{tempfile.path}".split(' ') }
  #
  #       context 'and the password is correct' do
  #         let(:attempts) { 1 }
  #
  #         before do
  #           allow(input_handler).to receive(:output).at_most(10).times
  #           expect(input_handler).to receive(:prompt).exactly(1).times.and_return(password)
  #           application.input_handler = input_handler
  #         end
  #
  #         include_context :run_command
  #
  #         it 'should decrypt' do
  #           expect(decrypted_string).to eql(string)
  #           expect(tempfile_key).to eql(encrypted_key)
  #           expect(tempfile_key).not_to eql(key)
  #         end
  #
  #       end
  #
  #       context 'and has a wrong password' do
  #         let(:wrong_password) { 'barhoohaaa' }
  #         let(:attempts) { 3 }
  #
  #         it 'should store the key in a temporary file' do
  #           expect(tempfile_key).to eq encrypted_key
  #           expect(tempfile_key).not_to eq key
  #         end
  #
  #         context 'should not decrypt' do
  #           before do
  #             allow(input_handler).to receive(:output).at_most(10).times
  #             allow(input_handler).to receive(:prompt).exactly(attempts).times.and_return(wrong_password)
  #             application.input_handler = input_handler
  #           end
  #
  #           include_context :run_command
  #
  #           it { should_not eq(string) }
  #         end
  #       end
  #    end
  #  end
  # end
end
