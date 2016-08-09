require 'spec_helper'
require 'singleton'

module Secrets
  module App
    module Commands
      class FakeCommand < ::Secrets::App::Commands::Command
        include Secrets
        required_options :fake, [:one, :other], ->(arg) { arg[:booboo].eql?(:doodoo) }
      end
      RSpec.describe 'Secrets::App::Commands' do
        let(:fake) { FakeCommand }

        context 'command set' do
          subject { Secrets::App::Commands }
          it 'should have registered the commands' do
            expect(subject.commands).to include(Secrets::App::Commands::FakeCommand)
            expect(subject.commands).to include(Secrets::App::Commands::EncryptDecrypt)
          end
        end

        context 'required_options' do
          it 'should register required options for each command' do
            expect(fake.required_options.to_a).to include(:fake)
          end
          it 'should select the command based on required options with OR' do
            expect(Secrets::App::Commands.find_command_class({ fake: true, one: true })).to eql(FakeCommand)
          end
          it 'should select the command based on required options with OR' do
            expect(Secrets::App::Commands.find_command_class({ fake: true, other: true })).to eql(FakeCommand)
          end
          it 'should not select the command without all options satisfied' do
            expect(Secrets::App::Commands.find_command_class({ fake: true })).to be_nil
          end
          it 'should select a command based on a proc' do
            expect(Secrets::App::Commands.find_command_class({ booboo: :doodoo })).to eql(FakeCommand)
          end
        end

        context 'EncryptDecrypt' do
          subject { Secrets::App::Commands::EncryptDecrypt }
          let(:options_variations) {
            [
              { decrypt: true, string: 'hello', private_key: FakeCommand.private_key },
              { encrypt: true, file: 'file.txt', private_key: FakeCommand.private_key }
            ]
          }
          it 'should find the command' do
            options_variations.each do |opts|
              expect(Secrets::App::Commands.find_command_class(opts)).to eql(subject)
            end
          end
        end
      end
    end
  end
end
