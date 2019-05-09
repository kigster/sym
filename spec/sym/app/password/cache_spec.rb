require 'spec_helper'
require 'sym/app/password/providers'

RSpec.describe Sym::App::Password::Cache do
  let(:enabled) { true }
  let(:cache) do
    described_class.instance.configure(
      provider: :memcached,
      timeout:  200,
      enabled:  enabled
    )
  end

  context 'cache provider' do
    subject { cache.provider }
    it { is_expected.to be_kind_of(Sym::App::Password::Providers::MemcachedProvider) }
  end

  context 'cache enabled' do
    it 'is expected to set parameters correctly' do
      expect(cache.timeout).to eq(200)
      expect(cache.enabled).to be_truthy
    end

    context 'cache is live' do
      it 'should be alive and running' do
        expect(cache.provider.alive?).to be true
      end

      context 'storing data' do
        before do
          cache.provider.clear
        end

        it 'should write and read data' do
          expect(cache['greeting']).to be_nil
          cache['greeting'] = 'hello'
          expect(cache['greeting']).to eql('hello')
        end
      end
    end
  end

  context 'cache disabled' do
    let(:enabled) { false }
    it 'should properly set enabled to false' do
      expect(cache.enabled).to be false
    end

    it 'should not cache values' do
      cache['foo'] = 'bar'
      expect(cache['foo']).to be_nil
    end
  end
end

