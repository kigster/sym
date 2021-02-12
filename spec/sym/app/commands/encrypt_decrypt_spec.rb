require 'spec_helper'
require 'digest'
module Sym
  module App
    module Commands
      RSpec.describe 'Encrypting and Decrypting' do
        include_context 'commands'

        context 'encrypt' do
          let(:argv) { "-e -k #{key} -s hello ".split }
          let(:command_class) { ::Sym::App::Commands::Encrypt }
          let(:encrypted_data) { program_output }

          it 'invokes the Encrypt command' do
            expect_command_to_have klass:  Commands::Encrypt,
                                   output: [/[a-zA-Z0-9\-_=]{44}/],
                                   value:  true,
                                   lines:  1
          end

          it 'encrypts data' do
            expect(encrypted_data).not_to eq('hello')
          end

          context 'decrypt' do
            let(:options) { %i(key decrypt string verbose trace) }
            let(:options_hash) { h = Hash.new; options.each { |k| h[k] = true }; h }
            let(:decrypted_data) { TestClass.new.decr(program_output, key) }

            it 'matches the command with options' do
              expect(options_hash[:decrypt]).to be_truthy
              expect(::Sym::App::Commands::Decrypt).to be_options_satisfied_by(options_hash)
            end

            it 'decrypts the string' do
              expect(decrypted_data).to eql('hello')
            end
          end
        end
      end
    end
  end
end
