require 'spec_helper'
require 'singleton'

module Sym
  module App
    module Commands
      class FakeCommand < ::Sym::App::Commands::BaseCommand
        include Sym::Crypt
        required_options :fake, [:one, :other], ->(arg) { arg[:booboo].eql?(:doodoo) }
      end
      RSpec.describe 'Sym::App::Commands' do
        let(:fake) { FakeCommand }

        context 'command set' do
          subject { Sym::App::Commands }
          it 'should have registered the commands' do
            expect(subject.commands).to include(Sym::App::Commands::FakeCommand)
            expect(subject.commands).to include(Sym::App::Commands::Encrypt)
            expect(subject.commands).to include(Sym::App::Commands::Decrypt)
          end
        end

        context 'command ordering' do
          subject { Sym::App::Commands }
          it 'should have registered the commands' do
            expect(subject.sorted_commands.map(&:short_name).first).to eql(:show_help)
            expect(subject.sorted_commands.first).to eql(Sym::App::Commands::ShowHelp)
          end
        end

        context 'required_options' do
          it 'should register required options for each command' do
            expect(fake.required_options.to_a).to include(:fake)
          end
          it 'should select the command based on required options with OR' do
            expect(Sym::App::Commands.find_command_class({ fake: true, one: true })).to eq(FakeCommand)
          end
          it 'should select the command based on required options with OR' do
            expect(Sym::App::Commands.find_command_class({ fake: true, other: true })).to eq(FakeCommand)
          end
          it 'should not select the command without all options satisfied' do
            expect(Sym::App::Commands.find_command_class({ fake: true })).to be_nil
          end
          it 'should not select the command without all options satisfied' do
            expect(Sym::App::Commands.find_command_class({ help: true, trace: true })).to eq(ShowHelp)
          end
          it 'should not select the command without all options satisfied' do
            expect(Sym::App::Commands.find_command_class({ decrypt: false,
                                                           edit: false,
                                                           generate: false,
                                                           password: false,
                                                           keychain: nil,
                                                           key: nil,
                                                           interactive: false,
                                                           cache_passwords: false,
                                                           cache_timeout: nil,
                                                           cache_provider: nil,
                                                           string: nil,
                                                           file: nil,
                                                           output: nil,
                                                           backup: false,
                                                           verbose: false,
                                                           quiet: false,
                                                           trace: true,
                                                           debug: false,
                                                           version: true,
                                                           no_color: false,
                                                           no_environment: false,
                                                           bash_support: nil,
                                                           examples: false,
                                                           help: false })).to eq(ShowVersion)
          end
          it 'should select a command based on a proc' do
            expect(Sym::App::Commands.find_command_class({ booboo: :doodoo })).to eq(FakeCommand)
          end
        end

        context 'Encrypt' do
          subject { Sym::App::Commands::Encrypt }
          let(:options_variations) {
            [
              { encrypt: true, string: 'hello', key: FakeCommand.private_key },
              { encrypt: true, file: 'file.txt', key: FakeCommand.private_key },
            ]
          }
          it 'should find the command' do
            expect(Sym::App::Commands.commands.size).to be >= 9
            options_variations.each do |opts|
              expect(Sym::App::Commands.find_command_class(opts)).to eql(subject), opts.inspect
            end
          end
        end
        context 'Decrypt' do
          subject { Sym::App::Commands::Decrypt }
          let(:options_variations) {
            [
              { decrypt: true, string: 'hello', key: FakeCommand.private_key },
              { decrypt: true, file: 'file.txt', key: FakeCommand.private_key, verbose: true, trace: true }
            ]
          }
          it 'should find the command' do
            expect(Sym::App::Commands.commands.size).to be >= 9
            options_variations.each do |opts|
              expect(Sym::App::Commands.find_command_class(opts)).to eql(subject), opts.inspect
            end
          end
        end
      end
    end
  end
end
