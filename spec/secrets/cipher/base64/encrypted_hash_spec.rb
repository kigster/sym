require 'spec_helper'
require 'secrets/cipher/base64/encrypted_hash'
require 'yaml'

module Secrets::Cipher::Base64
  describe EncryptedHash do
    let(:secret) { EncryptedHash.create_secret }
    let(:hash) {
      {
        'name'     => { 'first' => 'Konstantin', 'last' => 'Gredeskoul' },
        'address'  => { 'street1'       => '1 Market Street, Apt 000',
                        'street2'       => nil,
                        'city'          => 'San Francisco',
                        'state'         => 'CA',
                        'zip'           => 94107,
                        'home_address?' => true },
        'password' => "Wouldn't you like to know!"
      }
    }
    let(:hash_unencrypted) { EncryptedHash.new(hash) }
    let(:hash_encrypted) { hash_unencrypted.encrypt(secret) }
    let(:hash_decrypted) { hash_encrypted.decrypt(secret) }

    let(:yaml_unencrypted) { hash_unencrypted.to_hash.to_yaml }
    let(:yaml_encrypted) { hash_encrypted.to_hash.to_yaml }
    let(:yaml_decrypted) { hash_decrypted.to_hash.to_yaml }

    context '#encrypt' do
      subject { hash_encrypted }
      it { is_expected.to_not be_nil }
      it { is_expected.to_not eql(hash) }
      it { is_expected.to respond_to(:name) }
      it 'should not have equal attributes' do
        expect(hash_encrypted.name).to_not eql(hash[:name])
      end
    end

    context '#decrypt' do
      subject { hash_decrypted }
      it { is_expected.to_not be_nil }
      it { is_expected.to eql(hash) }
      it { is_expected.to respond_to(:name) }
      it 'should work for Fixnums' do
        expect(hash['address']['zip']).to eql(94107)
        expect(hash_decrypted['address']['zip']).to eql(94107)
      end
    end

    context '#yaml' do
      it 'should be able to encrypt and decrypt back yaml' do
        expect(yaml_unencrypted).to eql(yaml_decrypted)
      end
    end
  end
end
