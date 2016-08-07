require 'spec_helper'
require 'yaml'

module Secrets
  module Encrypted
    describe HashData do
      let(:secret) { Secrets::Encrypted::HashData.secret }
      let(:hash) {
        {
          'name'                  => { 'first' => 'Konstantin',
                                       'last'  => 'Gredeskoul' },
          'address'               => { 'street1'       => '1 Market Street, Apt 000',
                                       'street2'       => nil,
                                       'city'          => 'San Francisco',
                                       'state'         => 'CA',
                                       'zip'           => 94107,
                                       'home_address?' => true },
          'password'              => "Wouldn't you like to know!",
          'height'                => 6.2,
          'weight'                => 182.1,
          'complexity_score'      => 1+0i,
          'rationalization_score' => '34.12/4'.to_r,
          'family symbol'         => :lion
        }
      }

      let(:hd) { Secrets::Encrypted::HashData.new(hash) }
      let(:hash_encrypted) { hd.encrypt(secret) }
      let(:hd_encrypted) { Secrets::Encrypted::HashData.new(hash_encrypted) }
      let(:hash_decrypted) { hd_encrypted.decrypt(secret) }

      let(:yaml_unencrypted) { hash.to_yaml }
      let(:yaml_encrypted) { hash_encrypted.to_yaml }
      let(:yaml_decrypted) { hash_decrypted.to_yaml }

      context 'encrypted_hash' do
        subject { hash_encrypted }
        it { is_expected.to_not be_nil }
        it { is_expected.to_not eql(hash) }
      end

      context 'encrypted hash data' do
        subject { hd_encrypted }
        it 'should have encrypted hash values' do
          expect(subject.data['name']).to_not eql(hash['name'])
          expect(subject.data['name']['first']).to_not eql(hash['name']['first'])
        end
      end

      context 'hash_decrypted' do
        subject { hash_decrypted }
        it { is_expected.to_not be_nil }
        it { is_expected.to eql(hash) }
        it 'is expected to have propertly decoded value classes' do
          expect(subject['address']['zip']).to eql(94107)
          expect(subject['height']).to eql(6.2)
          expect(subject['complexity_score']).to eql(1+0i)
          expect(subject['rationalization_score']).to eql('34.12/4'.to_r)
          expect(subject['family symbol']).to eql(:lion)
        end
      end


      context 'hd_decrypted' do
        it 'should work for Fixnums' do
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
end
