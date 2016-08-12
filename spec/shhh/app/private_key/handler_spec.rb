require 'spec_helper'
require 'singleton'

module Shhh
  module App
    RSpec.describe Shhh::App::PrivateKey::Handler do
      include_context :test_instance

      let(:private_key) { test_class.create_private_key }

      subject { Shhh::App::PrivateKey::Handler.new(opts).key }

      context 'in both cases, where the key is ' do
        context 'unencrypted' do
          let(:opts) { { private_key: private_key } }
          let(:argv) { "-k #{private_key} ".split(' ') }
          context 'shows unencrypted private keys' do
            it { is_expected.to eql(private_key) }
          end
        end

        context 'encrypted' do
          let(:password) { 'whatsup' }
          let(:encrypted_key) { test_instance.encr_password(private_key, password) }
          let(:opts) { { private_key: encrypted_key } }

          before do
            expect(Shhh::App::Input::Handler).to receive(:ask).once.and_return(password)
          end
          context 'shows the decrypted private keys' do
            it { is_expected.to eql(private_key) }
          end
        end
      end

    end
  end
end

