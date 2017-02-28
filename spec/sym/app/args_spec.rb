require 'sym/app/output/base'
require 'spec_helper'
require 'singleton'

module Sym
  module App
    RSpec.describe Sym::App::Args do
      let(:opts) { { key: true, edit: true } }
      let(:args) { Args.new(opts) }

      %i(specify_key?
         require_key?).each do |type|
        context "##{type.to_s}" do
          subject { args.send(type) }
          it { is_expected.to be_truthy }
        end
      end

      context 'requires key or not?' do
        subject { args.require_key? }
        context '--examples' do
          let(:opts) { { examples: true } }
          it { is_expected.to be_falsey }
        end
        context '--generate' do
          let(:opts) { { generate: true } }
          %i(generate_key?).each do |type|
            context "##{type.to_s}" do
              subject { args.send(type) }
              it { is_expected.to be_truthy }
            end
          end

          it 'should only have :generate in the options' do
            expect(opts.keys).to eql([:generate])
          end
          it { is_expected.to be_falsey }
        end
        context '--decrypt' do
          let(:opts) { { decrypt: true } }
          it { is_expected.to be_truthy }
        end
      end

      { nil     => Sym::App::Output::Stdout,
        :output => Sym::App::Output::File,
        :quiet  => Sym::App::Output::Noop
      }.each_pair do |option, klass|
        context klass.name do
          let(:opts) { { option => true } }

          context 'required_option' do
            it 'should have appropriate required_option set' do
              expect(klass.required_option).to eql(option)
            end
          end

          it 'should already be in the options hash' do
            expect(Sym::App::Output.outputs).to be_a(Hash)
            expect(Sym::App::Output.outputs.key?(option)).to be_truthy
          end

          it "should be invoked by option [#{option.to_s}]" do
            expect(Sym::App::Output.outputs[option]).to eql(klass)
          end

          it 'should return correct output class from opts' do
            expect(args.output_class).to eql(klass)
          end
        end
      end
    end
  end
end
