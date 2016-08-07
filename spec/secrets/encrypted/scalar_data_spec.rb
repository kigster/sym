require 'spec_helper'
require 'secrets/encrypted/scalar_data'

module Secrets
  module Encrypted
    describe ScalarData do
      let(:scalar_type) { Secrets::Encrypted::ScalarData }
      let(:secret) { scalar_type.secret }

      SCALARS = ['hello world', 123550, 1249843.43211, '1.3/5'.to_r, 1+5i]

      context 'initialization' do
        subject { scalar_type.new('bahahaha') }
        it { is_expected.to respond_to(:decrypt) }
        it { is_expected.to respond_to(:encrypt) }
        it 'should save the constructor data' do
          expect(subject.data).to eql('bahahaha')
        end
      end

      context 'secret' do
        subject { ::Base64.decode64(secret).length }
        it { is_expected.to eql(32) }
      end

      context 'scalar values' do
        SCALARS.each do |scalar_value|
          context scalar_value.class.name do
            let(:scalar) { scalar_value }
            let(:scalar_data1) { scalar_type.new(scalar) }
            let(:encrypted_scalar) { scalar_data1.encrypt(secret) }
            let(:scalar_data2) { scalar_type.new(encrypted_scalar) }

            subject { scalar_data2.decrypt(secret) }
            it { is_expected.to eql(scalar) }
            it { is_expected.to_not eql(encrypted_scalar) }
          end
        end
      end
    end
  end
end
