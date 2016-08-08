require 'spec_helper'

module Secrets
  describe Secrets do
    include_context :module_included

    it 'has a version number' do
      expect(VERSION).not_to be nil
    end

    context '#private_key' do
      include_context :abc_classes
      it 'should assign and save private key' do
        expect(AClass.private_key).to eql(AClass.private_key)
        expect(BClass.private_key).to eql(BClass.private_key)
        expect(CClass.private_key).to eql(c_private_key)
      end
      it 'should save private key per class' do
        expect(AClass.private_key).not_to eql(BClass.private_key)
        expect(CClass.private_key).not_to eql(BClass.private_key)
        expect(CClass.private_key).not_to eql(AClass.private_key)
      end
    end

    describe 'instance methods' do
      context '#encr and #decr methods' do
        subject { test_instance }
        it { is_expected.to respond_to(:encr) }
        it { is_expected.to respond_to(:decr) }
      end

      it '#create_private_key' do
        expect(::Base64.decode64(test_instance.class.create_private_key).size).to eql(32)
        expect(test_instance.class.create_private_key).not_to eql(test_instance.class.create_private_key)
      end

      context 'encrypting and decrypting' do
        let(:secret) { test_instance.class.create_private_key }
        let(:private_key) { 'My girlfriend brings all the boys to the yard' }
        it 'should be able to decrypt encrypted message' do
          encrypted_string = test_instance.encr(private_key, secret)
          expect(test_instance.decr(encrypted_string, secret)).to eql(private_key)
        end
      end
    end
  end
end

