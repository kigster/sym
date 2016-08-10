require 'spec_helper'
require 'singleton'
require 'secrets/app/keychain'
module Secrets
  module App
    RSpec.describe 'Secrets::App::KeyChain' do
      let(:opts) { { verbose: false } }
      let(:key_name) { 'silky-smooth-chocolate'}
      let(:keychain) { Secrets::App::KeyChain.new(key_name, opts) }
      let(:commands) { %w(add find delete) }
      let(:password) { 'Sup4r!Secur3' }

      BASE_VARS = {
        user:        ENV['USER'],
        kind:        'secrets-cipher-base64',
        sub_section: 'generic-password'
      }

      context 'class variables' do
        BASE_VARS.each_pair do |variable, value|
          it "variable #{variable} should be set to value #{value}" do
            expect(KeyChain.send(variable)).to eql(value)
          end
          it "variable #{variable} should not be nil" do
            expect(KeyChain.send(variable)).to_not be_nil
          end
        end
      end

      context '#execute' do
        it 'should run a command successfully' do
          expect(keychain.execute('pwd')).to eql(Dir.pwd)
        end
      end

      if Secrets::App.is_osx?
        context 'integration tests' do
          before do
            keychain.stderr_off
            keychain.delete rescue nil  # delete in case it's already there
          end
          after do
            keychain.stderr_on
          end
          it 'should add a new key' do
            keychain.add(password)
            expect(keychain.find).to eql(password)
            keychain.delete
          end
        end
      end
    end
  end
end

