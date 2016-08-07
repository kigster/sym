require 'spec_helper'
require 'singleton'

module Secrets
  module App
    class OutputCollector
      APPENDER = ->(argument) { instance.append(argument) }
      include Singleton
      attr_accessor :output

      def append(arg)
        self.output ||= []
        self.output << arg
      end

      def reset
        self.output = []
      end
    end

    RSpec.describe CLI do
      let(:output_collector) { Secrets::App::OutputCollector.instance }
      let(:output) { output_collector.output }
      let(:cli) { CLI.new(argv) }
      let(:opts) { cli.opts }
      let(:config) { cli.c }
      let(:secret) { Secrets.create_secret }
      before do
        output_collector.reset
        cli.output = Secrets::App::OutputCollector::APPENDER
        cli.run
      end

      context '#generate' do
        let(:argv) { %w(-g) }
        it 'should output the generated secret' do
          expect(config.generate == true).to be_truthy
          expect(output.first.size).to eql(45)
        end
      end
      context '#version' do
        let(:argv) { %w(-V) }
        it 'should output the version number' do
          expect(config.version == true).to be_truthy
          expect(output.first).to eql("secrets-cipher-base64 (version #{Secrets::VERSION})")
        end
      end
      context 'encryption' do
        let(:phrase) { 'HelloWorld' }
        let(:secret) { 'dp95EE/dIXodTvwiwxcFYiRpDe1WcF7mbIQqvzWlprM=' }
        let(:argv) { "-e -p #{phrase} -s #{secret}".split(/\s/) }
        let(:encrypted) { output.first }
        it 'should output the encrypted data' do
          expect(config.encrypt == true).to be_truthy
          expect(config.phrase).to eql(phrase)
          expect(config.secret).to eql(secret)
          expect(encrypted).to_not be_nil
          expect(encrypted).to_not eql(phrase)
        end

        context 'decryption' do
          let(:decrypt_argv) { "-d -p #{encrypted} -s #{secret} -v".split(/\s/) }
          let(:decrypt_cli) { CLI.new(decrypt_argv) }

          it 'should be able to decrypt encrypted data' do
            decrypt_cli.output = Secrets::App::OutputCollector::APPENDER
            decrypt_cli.run
            decrypted = output.last
            expect(decrypted).to eql(phrase)
          end
        end
      end
    end
  end
end
