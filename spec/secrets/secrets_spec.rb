require 'spec_helper'

module Secrets
  describe 'Secrets' do
    it 'has a version number' do
      expect(Secrets::VERSION).not_to be nil
    end

    context '#secret' do
      include_context :module_included

      describe 'instance methods' do
        context '#encr and #decr methods' do
          subject { test_instance }
          it { is_expected.to respond_to(:encr) }
          it { is_expected.to respond_to(:decr) }

        end
        it '#create_secret' do
          expect(::Base64.decode64(test_instance.class.create_secret).size).to eql(32)
          expect(test_instance.class.create_secret).not_to eql(test_instance.class.create_secret)
        end

        context 'encrypting and decrypting' do
          let(:secret) { test_instance.class.create_secret }
          let(:secret_string) { 'My girlfriend brings all the boys to the yard' }
          it 'should be able to decrypt encrypted message' do
            encrypted_string = test_instance.encr(secret_string, secret)
            expect(test_instance.decr(encrypted_string, secret)).to eql(secret_string)
          end
        end
      end
    end
  end
end
