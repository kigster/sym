require 'spec_helper'
require 'shhh/encrypted_file'

module Shhh
  module App
    RSpec.describe Shhh::EncryptedFile do

      context 'decrypting and initializing' do
        let(:file_encrypted) { 'spec/fixtures/secrets.yml.enc' }
        let(:file_original) { 'spec/fixtures/secrets.yml' }
        let(:keyfile) { 'spec/fixtures/secrets.key' }

        let(:key) { File.read(keyfile) }

        let(:args) { {
          file:     file_encrypted,
          key_id:   keyfile,
          key_type: :keyfile
        } }

        let!(:efile) { Shhh::EncryptedFile.new(args) }

        context 'initializing file' do
          it 'should properly initialize' do
            expect(efile).to_not be_nil
            expect(efile.read).to eql(File.read(file_original))
          end
        end
      end
    end
  end
end
