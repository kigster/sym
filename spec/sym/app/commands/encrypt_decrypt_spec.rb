# frozen_string_literal: true

require 'spec_helper'
require 'digest'
module Sym
  module App
    module Commands
      RSpec.describe 'Encrypting and Decrypting' do
        include_context :commands

        context 'encrypt' do
          let(:argv) { "-e -k #{key} -s hello ".split(' ') }
          let(:command_class) { ::Sym::App::Commands::Encrypt }
          let(:encrypted_data) { program_output }

          it 'should invoke the Encrypt command' do
            expect_command_to_have klass: Commands::Encrypt,
                                   output: [/[a-zA-Z0-9\-_=]{44}/],
                                   value: true,
                                   lines: 1,
                                   program_output: program_output_lines
          end

          it 'should encrypt data' do
            expect(encrypted_data).to_not eq('hello')
          end

          context 'decrypt' do
            let(:options) { %i(key decrypt string verbose trace) }
            let(:options_hash) { h = {}; options.each { |k| h[k] = true }; h }
            let(:decrypted_data) { TestClass.new.decr(program_output, key) }

            it 'should match the command with options' do
              expect(options_hash[:decrypt]).to be_truthy
              expect(::Sym::App::Commands::Decrypt.options_satisfied_by?(options_hash)).to be_truthy
            end

            it 'should decrypt the string' do
              expect(decrypted_data).to eql('hello')
            end
          end
        end
      end
    end
  end
end
