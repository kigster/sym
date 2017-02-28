require 'spec_helper'
require 'sym/app/private_key/reader'

module Sym
  module App
    module PrivateKey
      RSpec.describe ::Sym::App::PrivateKey::Reader do
        include_context :encryption

        let(:input_handler) { Sym::App::Input::Handler.new }
        let(:password_handler) { Sym::App::Password::Cache.instance.configure(enabled: false) }
        let(:data) { key }

        subject { ::Sym::App::PrivateKey::Reader.new(data, input_handler, password_handler).key }

        context 'from a string' do
          it { is_expected.to eql(key) }
        end

        context 'from a file' do
          let(:tempfile) { Tempfile.new('boo') }
          let(:data) { tempfile.path }

          before do
            tempfile.write(key)
            tempfile.flush
          end

          it 'should read private key from the tempfile' do
            expect(File.read(tempfile.path)).to eq(key)
            expect(key.length).to eq(44)
          end

          it { is_expected.to eq(key) }
        end

        context 'from keychain' do
          let(:keychain_name) { 'keychain-name' }
          let(:data) { keychain_name }

          context 'valid key' do
            before { expect(KeyChain).to receive(:get).with(keychain_name).and_return(key) }
            it { is_expected.to eql(key) }
          end

          context 'invalid key' do
            before { expect(KeyChain).to receive(:get).with(keychain_name).and_return('boo!') }
            it { is_expected.to be_nil }
          end
        end

        context 'from environment' do
          let(:data) { 'PRIVATE_KEY' }
          context 'valid key' do
            before do
              allow(ENV).to receive(:[]).with('MEMCACHE_USERNAME')
              allow(ENV).to receive(:[]).with(data).and_return(key)
            end

            it { is_expected.to eql(key) }
          end

          context 'invalid key' do
            before do
              allow(ENV).to receive(:[]).with('MEMCACHE_USERNAME')
              allow(ENV).to receive(:[]).with(data).and_return(nil)
            end
            it { is_expected.to be_nil }
          end
        end
      end
    end
  end
end
