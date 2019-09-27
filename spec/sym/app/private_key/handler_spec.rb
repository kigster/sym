# frozen_string_literal: true

require 'spec_helper'
require 'singleton'
module Sym
  module App
    RSpec.describe Sym::App::PrivateKey::Handler do
      include_context :test_instance

      let(:key) { test_class.create_private_key }
      let(:input_handler) { Sym::App::Input::Handler.new }
      let(:password_handler) { Sym::App::Password::Cache.instance.configure(enabled: false) }

      subject { Sym::App::PrivateKey::Handler.new(opts, input_handler, password_handler).key }

      context 'in both cases, where the key is ' do
        context 'unencrypted' do
          let(:opts) { { key: key } }
          let(:argv) { "-k #{key} ".split(' ') }
          context 'shows unencrypted private keys' do
            it { is_expected.to eql(key) }
          end
        end

        context 'encrypted' do
          let(:password) { 'whatsup' }
          let(:encrypted_key) { test_instance.encr_password(key, password) }
          let(:opts) { { key: encrypted_key } }

          before do
            expect(input_handler).to receive(:ask).once.and_return(password)
          end
          context 'shows the decrypted private keys' do
            it { is_expected.to eql(key) }
          end
        end
      end
    end
  end
end
