require 'spec_helper'
require 'sym/extensions/ordered_hash'

module Sym
  RSpec.describe OrderedHash do
    let(:oh) { ::Sym::OrderedHash.new }

    before do
      oh[:a] = 3
      oh[:b] = 2
      oh[:c] = 1
    end

    context 'ordered keys' do
      subject { oh.keys }
      it { is_expected.to eq [:a, :b, :c] }
      it { is_expected.to eq oh.keys.sort }

      context 'deleting then adding' do
        before do
          oh.delete(:a)
          oh[:a] = 3
        end

        it { is_expected.to eq [:b, :c, :a] }
      end
    end

    context 'ordered values' do
      subject { oh.values }
      it { is_expected.to eq [3,2,1] }
      it { is_expected.to eq oh.values.sort { |x,y| y <=> x } }
    end


  end
end

