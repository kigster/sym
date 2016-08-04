require 'spec_helper'

describe Secrets::Cipher::Base64 do
  it 'has a version number' do
    expect(Secrets::Cipher::Base64::VERSION).not_to be nil
  end


  context '#secret' do
    include_context :module_included

    describe 'instance methods' do
      context '#encr and #decr methods' do
        subject { test_instance }
        it { is_expected.to respond_to(:encr) }
        it { is_expected.to respond_to(:decr) }
      end
    end

  end

end
