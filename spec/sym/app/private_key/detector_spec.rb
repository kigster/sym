# frozen_string_literal: true

require 'spec_helper'
require 'sym/app/private_key/detector'

module Sym
  module App
    module PrivateKey
      RSpec.describe ::Sym::App::PrivateKey::Detector do
        include_context :encryption

        let(:input_handler) { Sym::App::Input::Handler.new }
        let(:password_handler) { Sym::App::Password::Cache.instance.configure(enabled: false) }
        let(:data) { key }
        let(:opts) { { key: data } }
        subject(:reader) { ::Sym::App::PrivateKey::Detector.new(opts, input_handler, password_handler) }

        context 'from a string' do
          its(:key) { should eq(key) }
          its(:key_source) { should eq("string://[reducted]") }
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

          its(:key) { should eq(key) }
          its(:key_source) { should eq("file://#{tempfile.path}") }
        end

        context 'from keychain' do
          let(:keychain_name) { 'keychain-name' }
          let(:data) { keychain_name }

          context 'valid key' do
            before { expect(KeyChain).to receive(:get).with(keychain_name).and_return(key) }
            its(:key) { should eq(key) }
            its(:key_source) { should eq('keychain://keychain-name') }
          end

          context 'invalid key' do
            before { expect(KeyChain).to receive(:get).with(keychain_name).and_return('boo!') }
            its(:key) { is_expected.to be_nil }
            its(:key_source) { is_expected.to be_nil }
          end
        end

        context 'from environment' do
          let(:data) { 'PRIVATE_KEY' }
          context 'valid key' do
            before do
              allow(ENV).to receive(:[]).with('MEMCACHE_USERNAME')
              allow(ENV).to receive(:[]).with(data).and_return(key)
            end

            its(:key) { is_expected.to eq(key) }
            its(:key_source) { is_expected.to eq('env://PRIVATE_KEY') }
          end

          context 'invalid key' do
            before do
              allow(ENV).to receive(:[]).with('MEMCACHE_USERNAME')
              allow(ENV).to receive(:[]).with(data).and_return(nil)
            end
            its(:key) { is_expected.to be_nil }
            its(:key_source) { is_expected.to be_nil }
          end
        end

        context 'from a default file' do
          let(:data) { nil }
          before do
            expect(Sym).to receive(:default_key?).at_least(1).times.and_return(true)
            expect(Sym).to receive(:default_key).at_least(1).times.and_return(key)
          end

          its(:key) { should eq(key) }
          its(:key_source) { should start_with('default_file://') }
        end

        context 'from a an interactive input' do
          let(:opts) { { interactive: true } }
          before do
            expect(input_handler).to receive(:prompt).and_return(key)
          end
          its(:key) { should eq(key) }
          its(:key_source) { should start_with('interactive://[reducted]') }
        end
      end
    end
  end
end
