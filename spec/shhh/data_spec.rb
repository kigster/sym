require 'spec_helper'
require 'shhh/data'
module Shhh
  module Data
    RSpec.describe 'Shhh::Data' do
      let(:iv) { OpenSSL::Random.random_bytes 16 }
      let(:cipher_name) { Shhh::Configuration.property(:data_cipher) }
      let(:ws) { WrapperStruct.new(encrypted_data: 1234, iv: iv, cipher_name: cipher_name, salt: 'Boo') }

      context 'WrapperStruct' do

        def verify_wrapper_struct(struct)
          expect(struct.encrypted_data).to eql(1234)
          expect(struct.iv).to eql(iv)
          expect(struct.cipher_name).to eql(cipher_name)
          expect(struct.version).to eql(1)
          expect(struct.compress).to be_truthy
        end

        it 'should define cipher_name' do
          expect(cipher_name).to eql('AES-256-CBC')
        end

        it 'should define encrypted struct' do
          verify_wrapper_struct(ws)
        end

        it 'should be able to marshal and unmarshal encrypted data struct' do
          marshalled = Marshal.dump(ws)
          unmarshalled = Marshal.load(marshalled)
          expect(unmarshalled.class).to eql(WrapperStruct)
          verify_wrapper_struct(unmarshalled)
        end
      end

      context 'Encoder' do
        let(:encoder) { Encoder.new(ws, true) }
        let(:data_encoded) { encoder.data_encoded }
        it 'should encode wrapper_struct' do
          expect(data_encoded).to_not be_nil
          expect(ws.compress).to be_truthy
        end
        context 'Decoder' do
          let(:decoder) { Decoder.new(data_encoded, nil) }
          let(:decoded_struct) { decoder.data }
          it 'should decode and get original struct' do
            expect(decoded_struct).to eql(ws)
            expect(decoded_struct.compressed).to be_falsey
            expect(decoded_struct.salt).to eql('Boo')
          end
        end
      end
    end
  end
end
