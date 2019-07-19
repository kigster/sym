require 'spec_helper'
require 'base64'
# Requires:
#      let(:key) { .... }
#
shared_examples 'a private key' do
  subject { key }
  context 'base62 encoded key' do
    its(:length) { should be_between(42, 44) }
  end
  context 'base62 decoded key' do
    subject { Base64.urlsafe_decode64(key) }
    its(:length) { should eq(32) }
  end
end
