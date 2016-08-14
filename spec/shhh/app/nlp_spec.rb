require 'spec_helper'
require 'singleton'


module Shhh
  module App

    RSpec.describe 'Shhh::App::NLP' do
      # let(:argv) { command.split(' ')}
      # let(:nlp) { NLP.new(argv) }
      # let(:result) { nlp.process }

      describe %Q(encrypt file 'hello' using 1234 save to output.enc) do
        it { is_expected.to map_to(%w(--encrypt --file 'hello' --private_key 1234 --output output.enc)) }
      end

      describe %Q(edit file 'passwords.enc' ask the key) do
        it { is_expected.to map_to(%w(--edit --file 'passwords.enc' --interactive)) }
      end

      describe 'decrypt file /etc/secrets with key from $file save to ./secrets' do
        it { is_expected.to map_to(%w(--decrypt --file /etc/secrets --keyfile $file --output ./secrets)) }
      end

      if Shhh::App.is_osx?

        context 'when using the keychain' do
          describe 'generate key to the clipboard and keychain item mykey' do
            it { is_expected.to map_to(%w(--generate --copy --keychain mykey)) }
          end

          describe 'lock file $input with keychain $name' do
            it { is_expected.to map_to(%w(--encrypt --file $input --keychain $name)) }
          end
        end

      end
    end
  end
end
