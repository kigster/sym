require 'spec_helper'
require 'digest'
module Sym
  module App
    module Commands
      RSpec.describe OpenEditor do
        include_context :commands

        let(:fixture_file) { 'spec/fixtures/hamlet.enc' }
        let(:fixture_file_md5) { Digest::MD5.new(File.read(fixture_file)) }
        let(:argv) { "-t #{fixture_file} -k #{key} -v --trace -b".split(' ') }
        let(:command_class) { OpenEditor }

        def before_cli_run
          expect(application.command).to receive(:launch_editor).once.and_return(true)
        end

        context 'no changes' do
          it('should detect no changes') { expect(program_output).to match /No changes/ }
        end
      end
    end
  end
end
