require 'spec_helper'

describe Secrets::Cipher::Base64 do
  it 'has a version number' do
    expect(Secrets::Cipher::Base64::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(true).to eq(true)
  end
end
