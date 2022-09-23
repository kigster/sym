require 'spec_helper'

module Sym
  module App
    RSpec.describe Sym::Application do

      context 'basic initialization' do
        let(:opts) { { generate: true } }
        let(:application) { described_class.new(opts) }

        it 'properlies initialize' do
          expect(application).not_to be_nil
          expect(application.opts).not_to be_nil
          expect(application.opts[:generate]).to be_truthy
          expect(application.command).to be_a(Sym::App::Commands::GenerateKey)
        end
      end

      context 'negated option' do
        RSpec.shared_examples 'negated' do
          subject(:opts) { application.opts }

          let(:cli_opts) { { negate: source_file } }
          let(:application) { described_class.new(cli_opts) }

          it 'properlies initialize' do
            expect(opts.key?(:negate)).to be(false)
            expect(opts[:file]).to eq(source_file)
            expect(opts[:output]).to eq(dest_file)
            expect(opts[action]).to be(true)
          end
        end
        context 'negated encrypted file' do
          it_behaves_like 'negated' do
            let(:action) { :decrypt }
            let(:source_file) { 'file.yml.enc' }
            let(:dest_file) { 'file.yml' }
          end
        end

        context 'negated unencrypted file' do
          it_behaves_like 'negated' do
            let(:action) { :encrypt }
            let(:source_file) { 'file.yml' }
            let(:dest_file) { 'file.yml.enc' }
          end
        end
      end

      context 'editor' do
        let(:opts) { { help: true } }
        let(:application) { described_class.new(opts) }
        let(:existing_editor) { 'exe/sym' }
        let(:non_existing_editor) { '/tmp/broohaha/vim' }

        RSpec.shared_examples 'editor detection' do
          it 'returns the first valid editor from the list' do
            expect(application).not_to be_nil
            expect(application).to receive(:editors_to_try).
              and_return([non_existing_editor, existing_editor])
            expect(application.editor).to eql(existing_editor)
          end
        end

        it_behaves_like 'editor detection'

        context 'the EDITOR environment variable is nil' do
          it_behaves_like 'editor detection' do
            let(:non_existing_editor) { nil }
          end
        end
      end

      describe '#initialize_key_source' do
        include_examples 'encryption'

        RSpec.shared_examples 'a private key detection' do
          subject(:application) { described_class.new(opts) }

          let(:key_data) { private_key }
          let(:opts) { { encrypt: true, string: 'hello', key: key_data } }

          it 'does not have the default key' do
            expect(Sym.default_key?).to be(false)
          end

          context 'key supplied as a string' do
            before { application.send(:initialize_key_source) }

            its(:key) { is_expected.to eq(key) }
          end

          context 'key supplied as a file path' do
            let(:tempfile) { Tempfile.new('sym-rspec') }
            let(:key_data) { tempfile.path }

            before do
              tempfile.write(private_key)
              tempfile.flush
              application.send(:initialize_key_source)
            end

            its(:key) { is_expected.to eq(key) }

            it 'has the key' do
              expect(File.read(tempfile.path)).to eq(private_key)
            end
          end

          context 'key supplied as environment variable' do
            let(:key_data) { 'PRIVATE_KEY' }

            before do
              allow(ENV).to receive(:[]).with('MEMCACHE_USERNAME')
              allow(ENV).to receive(:[]).with('SYM_CACHE_TTL')
              expect(ENV).to receive(:[]).with(key_data).and_return(private_key)
              application.send(:initialize_key_source)
            end

            its(:key) { is_expected.to eq(key) }
          end

          context 'default key exists' do
            let(:key_data) { nil }

            before do
              expect(Sym).to receive(:default_key?).at_least(:once).and_return(true)
              expect(Sym).to receive(:default_key).at_least(:once).and_return(private_key)
              application.send(:initialize_key_source)
            end

            its(:key) { is_expected.to eq(key) }
            its(:key_source) { is_expected.to start_with('default_file://') }
          end
        end

        describe 'private key without a password' do
          it_behaves_like 'a private key detection' do
            let(:private_key) { key }
          end
        end

        describe 'private key with a password' do
          it_behaves_like 'a private key detection' do
            before do
              allow(application.input_handler).to receive(:ask).at_least(10).times.and_return(password)
              allow(ENV).to receive(:[]).with('SYM_PASSWORD').at_least(:once).and_return(password)
            end

            let(:password) { 'pIA44z!w04DS' }
            let(:private_key) { test_instance.encr_password(key, password) }
          end
        end
      end
    end
  end
end
