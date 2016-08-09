require 'spec_helper'
require 'secrets/app'
module Secrets
  module App
    RSpec.describe 'Secrets::App::CLI' do
      include_context :encryption

      let(:cli) { CLI.new(argv) }
      let(:opts) { cli.opts }
      let(:private_key) { TestClass.create_private_key }

      before :each do
        fake_terminal.clear!
        cli.output_proc = cli.print_proc = Secrets::App::FakeTerminal::APPENDER
      end

      context 'generate private key' do
        let(:argv) { %w(-g -v) }
        it 'should output the generated private_key' do
          cli.run
          expect_some_output
          expect(opts[:generate] == true).to be_truthy
          expect(fake_stdout.first.size).to eql(44)
          expect(fake_stdout.size).to eql(1)
        end
      end
      context 'show version' do
        let(:argv) { %w(-V) }
        it 'should output the version number' do
          cli.run
          expect_some_output
          expect(opts[:version] == true).to be_truthy
          expect(fake_stdout.first).to eql("secrets-cipher-base64 (version #{Secrets::VERSION})")
          expect(fake_stdout.size).to eql(1)
        end
      end
      context 'show examples' do
        let(:argv) { %w(-E) }
        it 'should output the examples' do
          cli.run
          expect_some_output
          expect(fake_stdout.join).to match(/secrets -g/)
        end
      end
      context 'insufficient arguments' do
        let(:argv) { [ '-k', private_key, '-v' ] }
        it 'should show an error' do
          expect(cli).to receive(:error).once
          cli.run
          expect(opts[:private_key]).to eql(private_key)
          expect(fake_stdout).to_not be_nil
          expect(fake_stdout.first).to match(/Usage/)
        end
      end

      context 'perform encryption' do
        let(:string) { 'HelloWorld' }
        let(:private_key) { 'Nmd+5640OhW5Ny4gByOSgny1U0ZLi6DiVLpktREdsSw=' }
        let(:argv) { "-e -s #{string} -k #{private_key} -v -T".split(/\s/) }
        let(:result) { fake_stdout.first }

        before do
          cli.run
        end

        it 'should output the encrypted data' do
          expect(opts[:encrypt] == true).to be_truthy
          expect(opts[:string]).to eql(string)
          expect(opts[:private_key]).to eql(private_key)
          expect(result).to_not be_nil
          expect(result).to_not eql(string)
        end

        context 'and decryption' do
          let(:decrypt_argv) { "-d -s #{result} -k #{private_key} -v".split(/\s/) }
          let(:decrypt_cli) { CLI.new(decrypt_argv) }

          it 'should decrypt encrypted data' do
            decrypt_cli.output_proc = Secrets::App::FakeTerminal::APPENDER
            decrypt_cli.run
            decrypted = fake_stdout.last
            expect(decrypted).to eql(string)
          end
        end
      end
    end
  end
end
