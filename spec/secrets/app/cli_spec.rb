require 'spec_helper'
require 'singleton'
require 'secrets/app'
module Secrets
  module App
    class OutputCollector
      APPENDER = ->(argument) { Secrets::App::OutputCollector.instance.append(argument) }
      include Singleton
      attr_accessor :lines

      def append(arg)
        self.lines ||= []
        self.lines << arg.split("\n")
        self.lines.flatten!.compact!
      end

      def reset
        self.lines = []
      end
    end

    RSpec.describe 'Command Line' do
      include_context :module_included

      let(:output_collector) { Secrets::App::OutputCollector.instance }
      let(:output_stdout) { output_collector.lines }
      let(:cli) { CLI.new(argv) }
      let(:opts) { cli.opts }
      let(:private_key) { TestClass.create_private_key }

      before :each do
        output_collector.reset
        cli.output_proc = Secrets::App::OutputCollector::APPENDER
        cli.print_proc = Secrets::App::OutputCollector::APPENDER
      end

      context 'generate private key' do
        let(:argv) { %w(-g -v) }
        it 'should output the generated private_key' do
          cli.run
          expect(opts[:generate] == true).to be_truthy
          expect(output_stdout.first.size).to eql(44)
          expect(output_stdout.size).to eql(1)
        end
      end
      context 'show version' do
        let(:argv) { %w(-V) }
        it 'should output the version number' do
          cli.run
          expect(opts[:version] == true).to be_truthy
          expect(output_stdout.first).to eql("secrets-cipher-base64 (version #{Secrets::VERSION})")
          expect(output_stdout.size).to eql(1)
        end
      end
      context 'show examples' do
        let(:argv) { %w(-E) }
        it 'should output the examples' do
          cli.run
          expect(output_stdout.first).to match(/EXAMPLES/)
        end
      end
      context 'insufficient arguments' do
        let(:argv) { [ '-k', private_key, '-v' ] }
        it 'should show an error' do
          expect(cli).to receive(:error).once
          cli.run
          expect(opts[:private_key]).to eql(private_key)
          expect(output_stdout).to_not be_nil
          expect(output_stdout.first).to match(/Usage/)
        end
      end

      context 'perform encryption' do
        let(:string) { 'HelloWorld' }
        let(:private_key) { 'dp95EE/dIXodTvwiwxcFYiRpDe1WcF7mbIQqvzWlprM=' }
        let(:argv) { "-e -s #{string} -k #{private_key} -v".split(/\s/) }
        let(:encrypted) { output_stdout.first }

        before do
          cli.run
        end
        it 'should output the encrypted data' do
          expect(opts[:encrypt] == true).to be_truthy
          expect(opts[:string]).to eql(string)
          expect(opts[:private_key]).to eql(private_key)
          expect(encrypted).to_not be_nil
          expect(encrypted).to_not eql(string)
        end

        context 'and decryption' do
          let(:decrypt_argv) { "-d -s #{encrypted} -k #{private_key} -v".split(/\s/) }
          let(:decrypt_cli) { CLI.new(decrypt_argv) }

          it 'should decrypt encrypted data' do
            decrypt_cli.output_proc = Secrets::App::OutputCollector::APPENDER
            decrypt_cli.run
            decrypted = output_stdout.last
            expect(decrypted).to eql(string)
          end
        end
      end
    end
  end
end
