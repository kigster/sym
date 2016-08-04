require 'spec_helper'
require 'secrets/cipher/base64/encrypted_data'

describe Secrets::Cipher::Base64::EncryptedData do
  let(:secret) { 'boohooo' }
  let(:data_class) { Secrets::Cipher::Base64::EncryptedData  }
  let(:data) { data_class.new(decrypted: 'hello world', secret: secret) }

  context '#initialize' do
    context 'decrypted initialization' do
      subject { data }
      it { is_expected.to respond_to(:decrypted) }
    end
  end

end

