require 'spec_helper'
require 'coin'
module Sym
  module App
    module Password

      RSpec.describe Cache do
        let(:enabled) { true }
        let(:cache) { Cache.instance.configure(provider: Coin, timeout: 200, enabled: enabled) }
        context 'cache provider' do
          subject { cache.provider }
          it { is_expected.to be(Coin) }
        end

        context 'cache enabled' do
          it 'is expected to set parameters correctly' do
            expect(cache.timeout).to eq(200)
            expect(cache.enabled).to be_truthy
          end

          context 'storing data' do
            it 'should write and read data' do
              cache['greeting'] = 'hello'
              expect(cache['greeting']).to eql('hello')
            end
          end
        end

        context 'cache disabled' do
          let(:enabled) { false }
          it 'should properly set enabled to false' do
            expect(cache.enabled).to be_falsey
          end
          it 'should not cache values' do
            cache['foo'] = 'bar'
            expect(cache['foo']).to be_nil
          end
        end


      end

    end
  end
end

