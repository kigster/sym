require 'spec_helper'
require 'sym/magic_file'

module Sym
  describe MagicFile do
    let(:pathname_encrypted) { 'spec/fixtures/hamlet.enc' }
    let(:pathname_decrypted) { 'spec/fixtures/hamlet.txt' }

    let(:magic_file_encrypted) { Sym::MagicFile.new(pathname_encrypted, key) }
    let(:magic_file_decrypted) { Sym::MagicFile.new(pathname_decrypted, key) }

    let(:decrypted_contents) { ::File.read(pathname_decrypted) }
    let(:encrypted_contents) { ::File.read(pathname_encrypted) }

    context 'key supplied as is' do
      let(:key) { TEST_KEY }
      it 'should transparently open file' do
        expect(magic_file_encrypted.opts[:file]).to eq(pathname_encrypted)
        expect(magic_file_encrypted.decrypt).to eq(decrypted_contents)
      end

      it 'should transparently read file' do
        expect(magic_file_encrypted.read).to eq(decrypted_contents)
      end
    end

    context 'with the key in ENV' do
      let(:key) { 'PRIVATE_KEY' }
      before do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('PRIVATE_KEY').and_return(TEST_KEY)
      end
      it 'should transparently read file' do
        expect(magic_file_encrypted.read).to eq(decrypted_contents)
      end
    end

    context 'encrypt' do
      let(:temp_encrypted) { '/tmp/sym-hamlet.enc' }
      let(:temp_decrypted) { '/tmp/sym-hamlet.txt' }

      let(:key) { TEST_KEY }

      before do
        FileUtils.rm(temp_encrypted) rescue nil
        expect(File.exists?(temp_encrypted)).to eq false
        magic_file_decrypted.encrypt_to(temp_encrypted)
      end

      it 'should transparently encrypt file' do
        expect(File.exist?(temp_encrypted)).to eq true
      end

      context 'decrypting and comparing' do
        before do
          FileUtils.rm(temp_decrypted) rescue nil
          expect(File.exists?(temp_decrypted)).to eq false
          magic_file_encrypted.decrypt_to(temp_decrypted)
        end

        it 'should be equal to hamlet in fixtures' do
          expect(File.read(temp_decrypted)).to eq(File.read(pathname_decrypted))
        end
      end
    end
  end
end


