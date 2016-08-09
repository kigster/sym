require 'spec_helper'

module Secrets
  module Extensions
    RSpec.describe Secrets::Extensions::InstanceMethods do
      include_context :encryption
      subject { instance }
      let(:extra_debug) { false }

      context '#encr and #decr methods' do
        it { is_expected.to respond_to(:encr) }
        it { is_expected.to respond_to(:decr) }
      end

      context 'encrypting and decrypting a short strings' do
        let(:private_key) { instance.class.create_private_key }
        let(:data) { 'My girlfriend brings all the boys to the yard' }
        it 'should be able to decrypt encrypted message' do
          data_encrypted = instance.encr(data, private_key)
          expect(instance.decr(data_encrypted, private_key)).to eql(data)
          expect(data_encrypted.length).to be > data.length
          puts ">> [short strings] Encrypted: #{data_encrypted.length}, Original: #{data.length}" if extra_debug
        end
      end

      context 'encrypting and decrypting a large file' do
        let(:private_key) { instance.class.create_private_key }
        let(:file) { 'spec/fixtures/hamlet.txt' }
        let(:password) { 'Very secure password here' }
        let(:data) { File.read(file) }
        it 'should be able to encrypt and decrypt with the password' do
          data_encrypted = instance.encr(data, private_key)
          expect(instance.decr(data_encrypted, private_key)).to eql(data)
          expect(data_encrypted.length).to be < data.length
          puts ">> [large file ] Encrypted: #{data_encrypted.length}, Original: #{data.length}"  if extra_debug
        end
      end

      context 'password encryption' do
        let(:file) { 'spec/fixtures/hamlet.txt' }
        let(:password) { 'Very secure password here' }
        let(:data) { File.read(file) }
        it 'should be able to encrypt and decrypt with the password' do
          data_encrypted = instance.encr_password(data, password)
          expect(data_encrypted).to_not be_nil
          puts ">> [password file ] Encrypted: #{data_encrypted.length}, Original: #{data.length}" if extra_debug
          data_decrypted = instance.decr_password(data_encrypted, password)
          expect(data_decrypted).to eql(data)
        end

      end
    end
  end
end
