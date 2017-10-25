require 'spec_helper'

module Sym
  describe Config do
    subject { described_class }
    it { is_expected.to eq(Sym::Config) }
    its(:ancestors) { should include(Sym::Crypt::Configuration) }
    its(:ancestors) { should include(Sym::Configurable) }

    describe 'Configuration instance' do
      subject(:config) { described_class.config }
      before do
        described_class.configure do |c|
          c.default_key_file = :default_key_file
          c.data_cipher = :data_cipher
        end
      end
      after do
        described_class.configure(&Sym::Config::DEFAULT_CONFIG)
      end

      its(:data_cipher) { should eq(:data_cipher) }
      its(:default_key_file) { should eq(:default_key_file) }
      its(:encrypted_file_extension) { should eq('enc')}
    end
  end

end


