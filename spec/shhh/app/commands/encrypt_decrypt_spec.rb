require 'spec_helper'
require 'digest'
module Shhh
  module App
    module Commands
      RSpec.describe EncryptDecrypt do
        include_context :commands

        context 'command can be found' do
          let(:options) { %i(decrypt keyfile string verbose, trace) }
          let(:argv) { "-e -k #{private_key} -s hello ".split(' ') }
          let(:command_class) { EncryptDecrypt }
          let(:options_hash) { h = Hash.new; options.each { |k| h[k] = true}; h }
          let(:decrypted_data) { TestClass.new.decr(program_output, private_key) }
          it 'should match the command with options' do
            expect(options_hash[:decrypt]).to be_truthy
            expect(EncryptDecrypt.options_satisfied_by?(options_hash)).to be_truthy
          end

          it 'should encrypt the string' do
            expect(decrypted_data).to eql('hello')
          end

        end
      end
    end
  end
end
