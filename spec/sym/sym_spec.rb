require 'spec_helper'

module Sym
  describe 'VERSION' do
    it 'has a version number' do
      expect(VERSION).not_to be nil
    end
  end

  describe 'Sym#private_key' do
    include_context :encryption
    it '#create_private_key' do
      expect(::Base64.urlsafe_decode64(instance.class.create_private_key).size).to be(32)
      expect(instance.class.create_private_key).not_to eql(instance.class.create_private_key)
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
  end
end

