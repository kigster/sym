require 'spec_helper'
require 'sym/app/commands/generate_key'
require 'sym'
require 'sym/constants'
require 'sym/application'

RSpec.describe 'CLI execution', :type => :aruba do

  BASE62_REGEX    = %r{^[a-zA-Z0-9=.\-_]+=$}
  KEY_PLAIN       = 'm4G6b7Lb-0bom5l8uxog_cL1x08mvH1ASsv1Svl3UGQ='
  HELLO_ENCRYPTED = 'BAhTOh1TeW06OkRhdGE6OldyYXBwZXJTdHJ1Y3QLOhNlbmNyeXB0ZWRfZGF0YSIluUtFV4ibk5B65MTjQMXvphsSi7pKPVXt9B2atfMD7cg6B2l2IhWp0jYYSo0CHrm0gWh57mDPOhBjaXBoZXJfbmFtZSIQQUVTLTI1Ni1DQkM6CXNhbHQwOgx2ZXJzaW9uaQY6DWNvbXByZXNzVA=='
  TEMP_FILE       = "/tmp/sym.#{rand % 8984798712}"
  RESET_TEMP_FILE = ->(*) { File.unlink(TEMP_FILE) if File.exist?(TEMP_FILE) }

  context 'using Aruba framework' do
    let(:command) { "exe/sym #{args}" }
    let(:output) { last_command_started.stdout.chomp }

    context 'install bash completion' do
      before &RESET_TEMP_FILE
      after &RESET_TEMP_FILE
      let(:args) { "--bash-completion #{TEMP_FILE}" }

      it 'should run command' do
        run_simple command
        expect(File.exist?(TEMP_FILE))
        expect(File.read(TEMP_FILE)).to include(Sym::Constants::Completion::Config[:script])
      end
    end

    context 'while running commands' do
      before { run_simple command }

      context 'examples' do
        let(:args) { '-E' }
        it 'should print examples' do
          expect(output).to match(/generate a new private key into an environment variable:/)
        end
      end

      context 'help' do
        let(:args) { '-h' }
        it 'should show help' do
          expect(output).to match(/encrypt\/decrypt data with a private key/)
        end
      end

      context 'generate' do
        let(:args) { '-g' }
        it 'should run command' do
          expect(output.size).to be_between(42, 44)
          expect(output).to match(BASE62_REGEX)
        end
      end

      context 'encrypt a string' do
        let(:args) { %Q{-e -k #{KEY_PLAIN} -s "hello"} }
        it 'should run command' do
          expect(output).to end_with('==')
          expect(output).to match(BASE62_REGEX)
        end
      end

      context 'decrypt a string' do
        let(:args) { "-d -k #{KEY_PLAIN} -s #{HELLO_ENCRYPTED}" }
        it 'should run command' do
          expect(output).to eq('hello')
        end
      end

      if Sym::App.is_osx?
        context 'import a key into keychain' do
          let(:args) { "-k #{KEY_PLAIN} -x MOO" }
          it 'should add to keychain' do
            expect(Sym::App::KeyChain.get('MOO')).to eq(KEY_PLAIN)
            expect(output).to eq(KEY_PLAIN)
          end
        end
      end

      context 'import a key into a file' do
        let(:tempfile) { Tempfile.new }
        let(:args) { "-k #{KEY_PLAIN} -o #{tempfile.path}" }
        it 'should add to keychain' do
          expect(File.read(tempfile.path)).to eq(KEY_PLAIN)
        end
      end

      context 'using a temporary file' do

        context 'encrypt with redirect' do
          let(:args) { %Q[-e -k #{KEY_PLAIN} -s "hello" -o #{TEMP_FILE} ] }

          it 'should run command' do
            RESET_TEMP_FILE.call
            run_simple command
            result = File.read(TEMP_FILE)
            expect(result).to end_with('==')
            expect(result).to match(BASE62_REGEX)
          end

          context 'decrypt from a redirect' do
            let(:args) { "-d -k #{KEY_PLAIN} -f #{TEMP_FILE}" }

            it 'should run command' do
              expect(File.exist?(TEMP_FILE)).to be true
              expect(output).to eq('hello')
            end

            after &RESET_TEMP_FILE
          end
        end
      end
    end
  end
end
