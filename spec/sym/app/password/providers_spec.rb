require 'spec_helper'
require 'sym/app/password/providers'

module Sym
  module App
    module Password

      RSpec.describe Providers do
        its(:providers) { should_not be_empty }
        its(:providers) { should include Providers::MemcachedProvider }

        before :each do
          Providers.detected = nil
        end

        context '#provider_from_arguments' do
          subject { Providers.send(:provider_from_argument, argument) }
          context 'when unknown' do
            let(:argument) { :something }
            it('should be nil') { is_expected.to be_nil }
          end
          context 'when :memcached' do
            let(:argument) { :memcached }
            it('be Memcached') { is_expected.to be_kind_of(Providers::MemcachedProvider) }
          end
        end

        context '#detect' do
          before do
            allow_any_instance_of(Providers::MemcachedProvider).to receive(:alive?).and_return(true)
          end
          its(:provider) { should eq(subject.detect) }
          its(:provider) { should be_kind_of(Providers::MemcachedProvider) }
        end

        context '#detect' do
          context 'none available' do
            before do
              subject.providers.each do |provider|
                expect_any_instance_of(provider).to receive(:alive?).at_least(1).times.and_return(false)
              end
            end
            its(:detect) { should be_nil }
          end

          context 'all available' do
            before do
              subject.providers.each do |provider|
                allow_any_instance_of(provider).to receive(:alive?).and_return(true)
              end
            end
            its(:detect) { should be_kind_of(subject.providers.first) }
            its(:detect) { should be_kind_of(Providers::MemcachedProvider) }
            its(:detect) { should respond_to(:read, :write, :alive?) }
          end
        end
      end


    end
  end
end

