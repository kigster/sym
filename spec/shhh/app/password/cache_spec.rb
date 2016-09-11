require 'spec_helper'
require 'coin'
module Shhh
  module App
    module Password

      RSpec.describe Cache do
        let(:cache) { Cache.new(provider: Coin) }
        subject { cache.provider }

        it { is_expected.to be(Coin)  }

        context 'storing data' do
          it 'should write and read data' do
            cache['greeting'] = 'hello'
            expect(cache['greeting']).to eql('hello')
          end
        end

      end

    end
  end
end

