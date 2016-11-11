require 'spec_helper'
require 'sym/encrypted_file'

module Sym
  module App
    RSpec.describe Sym::EncryptedFile do

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

        let!(:efile) { Sym::EncryptedFile.new(args) }

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
