require 'spec_helper'
require 'sym/app/password/providers'

module Sym
  module App
    module Password

      RSpec.describe Providers do
        before do
          described_class.detected = nil
        end

        its(:providers) { is_expected.not_to be_empty }
        its(:providers) { is_expected.to include Providers::MemcachedProvider }


        describe '#provider_from_arguments' do
          subject { described_class.send(:provider_from_argument, argument) }

          context 'when unknown' do
            let(:argument) { :something }

            it('is nil') { is_expected.to be_nil }
          end

          context 'when :memcached' do
            let(:argument) { :memcached }

            it('be Memcached') { is_expected.to be_a(Providers::MemcachedProvider) }
          end
        end

        describe '#detect' do
          before do
            allow_any_instance_of(Providers::MemcachedProvider).to receive(:alive?).and_return(true)
          end

          its(:provider) { is_expected.to eq(subject.detect) }
          its(:provider) { is_expected.to be_a(Providers::MemcachedProvider) }
        end

        describe '#detect' do
          context 'none available' do
            before do
              subject.providers.each do |provider|
                expect_any_instance_of(provider).to receive(:alive?).at_least(:once).and_return(false)
              end
            end

            its(:detect) { is_expected.to be_nil }
          end

          context 'all available' do
            before do
              subject.providers.each do |provider|
                allow_any_instance_of(provider).to receive(:alive?).and_return(true)
              end
            end

            its(:detect) { is_expected.to be_a(subject.providers.first) }
            its(:detect) { is_expected.to be_a(Providers::MemcachedProvider) }
            its(:detect) { is_expected.to respond_to(:read, :write, :alive?) }
          end
        end
      end


    end
  end
end

