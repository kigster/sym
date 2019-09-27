# frozen_string_literal: true

require 'spec_helper'

module Sym
  describe 'VERSION' do
    it 'has a version number' do
      expect(VERSION).not_to be nil
    end
  end

  describe Object do
    context '#present?' do
      it 'should properly respond to present' do
        expect(Object.new.present?).to be true
        expect(1.present?).to be true
        expect(''.present?).to be false
        expect(''.present?).to be false
        expect('hello'.present?).to be true
        expect(nil.present?).to be false
      end
    end
  end

  describe 'Sym#private_key' do
    include_context :encryption
    it '#create_private_key' do
      expect(::Base64.urlsafe_decode64(test_instance.class.create_private_key).size).to be(32)
      expect(test_instance.class.create_private_key).not_to eql(test_instance.class.create_private_key)
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
