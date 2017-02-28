require 'spec_helper'
require 'sym/app/password/providers'

module Sym
  module App
    module Password

      RSpec.describe Providers do
        its(:providers) { should_not be_empty }
        its(:providers) { should include *[Providers::MemcachedProvider,
                                           Providers::DrbProvider] }

        before :each do
          Providers.detected = nil
        end

        context '#provider_from_arguments' do
          subject { Providers.send(:provider_from_argument, argument) }
          context 'when unknown' do
            let(:argument) { :something }
            it('should be nil') { is_expected.to be_nil }
          end
          context 'when :drb' do
            let(:argument) { :drb }
            it('be DrbProvider') { is_expected.to be_kind_of(Providers::DrbProvider)}
          end
          context 'when :memcached' do
            let(:argument) { :memcached }
            it('be Memcached') { is_expected.to be_kind_of(Providers::MemcachedProvider)}
          end
        end

        context '#provider' do
          before do
            expect_any_instance_of(Providers::MemcachedProvider).to receive(:alive?).at_least(1).times.and_return(false)
          end
          its(:provider) { should eq(subject.detect) }
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
            its(:detect) { should respond_to(:read, :write, :alive?) }
          end

          context 'when memcached is not available' do
            before do
              expect_any_instance_of(Providers::MemcachedProvider).to receive(:alive?).and_return(false)
            end
            its(:detect) { should be_kind_of(Providers::DrbProvider) }
          end

          context 'when drb is not available' do
            let(:detected_provider_instance) {}
            let(:detected_provider_class) { detected_provider_instance.class }

            before do
              expect_any_instance_of(Providers::MemcachedProvider).to receive(:alive?).and_return(true)
            end

            it 'Dalli should have logger reset' do
              detected = subject.detect
              expect(detected).to be_kind_of(Providers::MemcachedProvider)
              expect(detected.class).to eq(Providers::MemcachedProvider)
              expect(Dalli.logger).to eq(Sym::Constants::Log::NIL)
            end
          end
        end
      end
    end
  end
end

