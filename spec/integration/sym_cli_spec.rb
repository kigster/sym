require 'spec_helper'
require 'sym/app/commands/generate_key'
require 'sym'
require 'sym/constants'
require 'sym/application'

RSpec.describe 'CLI execution', :type => :aruba do

  BASE62_REGEX    = %r{^[a-zA-Z0-9=.\-_]+=$}
  KEY_PLAIN       = 'm4G6b7Lb-0bom5l8uxog_cL1x08mvH1ASsv1Svl3UGQ='
  HELLO_ENCRYPTED = 'BAhTOh1TeW06OkRhdGE6OldyYXBwZXJTdHJ1Y3QLOhNlbmNyeXB0ZWRfZGF0YSIluUtFV4ibk5B65MTjQMXvphsSi7pKPVXt9B2atfMD7cg6B2l2IhWp0jYYSo0CHrm0gWh57mDPOhBjaXBoZXJfbmFtZSIQQUVTLTI1Ni1DQkM6CXNhbHQwOgx2ZXJzaW9uaQY6DWNvbXByZXNzVA=='
  USER_HOME       = "#{Dir.pwd}/temp"
  TEMP_FILE       = "#{USER_HOME}/sym.test.output"
  RESET_TEMP_FILE = ->(file = TEMP_FILE) do
    FileUtils.rm_rf(File.dirname(file))
    FileUtils.mkdir_p(File.dirname(file))
  end

  RESET_TEMP_FILE.call

  context 'using Aruba framework' do
    let(:command) { "exe/sym #{args}" }
    let(:output) { last_command_started.stdout.chomp }

    context 'install bash completion' do
      let(:args) { "-B #{TEMP_FILE}" }

      before { RESET_TEMP_FILE.call }

      before do
        File.open(TEMP_FILE, 'w') { |f| f.write("#!/usr/bin/env bash\n") }
        run_command_and_stop command, fail_on_error: true
      end

      it 'has two files to install' do
        expect(::Sym::Constants.config.size).to eq(2)
      end

      it 'runs command' do
        expect(File.exist?(TEMP_FILE)).to be(true)
        expect(File.read(TEMP_FILE)).to include(::Sym::Constants.config[:completion][:script])
        expect(File.read(TEMP_FILE)).to include(::Sym::Constants.config[:symit][:script])
      end
    end

    # TODO: collapse these two into a single shared example.
    context 'install bash completion with custom home dir' do
      let(:bashrc) { File.basename(TEMP_FILE) }
      let(:user_home) { '/tmp/user_home' }
      let(:outfile) { "#{user_home}/#{bashrc}" }
      let(:args) { "-B #{outfile} -u #{user_home} " }

      before do
        RESET_TEMP_FILE[outfile]
        FileUtils.mkdir_p(user_home)
        File.open(outfile, 'w') { |f| f.write("#!/usr/bin/env bash\n") }
        run_command_and_stop command, fail_on_error: true
      end

      it 'has two files to install' do
        expect(::Sym::Constants.config.size).to eq(2)
      end

      it 'has two files to install and they are the bash files from bin' do
        expect(::Sym::Constants::BASH_FILES.map { |f| File.basename(f) }.sort).to eq %w[sym.completion.bash sym.symit.bash]
      end

      context 'file contents' do
        subject { File.read(outfile) }

        it { is_expected.not_to be_nil  }
        it { is_expected.to include 'sym.completion.bash' }
      end
    end

    context 'while running commands' do
      before { run_command_and_stop command, fail_on_error: true }

      context 'examples' do
        let(:args) { '-E' }

        it 'prints examples' do
          expect(output).to match(/generate a new private key into an environment variable:/)
        end
      end

      context 'help' do
        let(:args) { '-h' }

        it 'shows help' do
          expect(output).to match(/encrypt\/decrypt data with a private key/)
        end
      end

      context 'generate' do
        let(:args) { '-g' }

        it 'runs command' do
          expect(output.size).to be_between(42, 44)
          expect(output).to match(BASE62_REGEX)
        end
      end

      context 'encrypt a string' do
        let(:string) { 'Hello, Dolly!' }
        let(:args) { %Q{-e -k #{KEY_PLAIN} -s "#{string}"} }

        it 'runs command' do
          expect(output).to match(BASE62_REGEX)
        end

        it 'decrypts back' do
          run_command_and_stop "exe/sym -d -k #{KEY_PLAIN} -s #{output}"
          expect(last_command_started.stdout.chomp).to eq(string)
        end
      end

      context 'decrypt a string' do
        let(:args) { "-d -k #{KEY_PLAIN} -s #{HELLO_ENCRYPTED}" }

        it 'runs command' do
          expect(output).to eq('hello')
        end
      end

      if Sym::App.osx? && ENV['KEYCHAIN_SPECS']
        context 'import a key into keychain' do
          let(:keychain_name) { 'mykey' }
          let(:args) { "-k #{KEY_PLAIN} -x #{keychain_name} " }

          before { (Sym::App::KeyChain.new(keychain_name).delete rescue nil) }


          it 'adds to keychain' do
            expect(output).to eq(KEY_PLAIN)
            expect(Sym::App::KeyChain.get(keychain_name)).to eq(KEY_PLAIN)
          end
        end
      end

      context 'import a key into a file' do
        let(:tempfile) { Tempfile.new('sym-rspec') }
        let(:args) { "-k #{KEY_PLAIN} -o #{tempfile.path}" }

        it 'adds to keychain' do
          expect(File.read(tempfile.path)).to eq(KEY_PLAIN)
        end
      end

      context 'using a temporary file' do
        context 'encrypt with redirect' do
          let(:args) { %Q[-e -k #{KEY_PLAIN} -s "hello\n" -o #{TEMP_FILE} ] }

          it 'runs command' do
            RESET_TEMP_FILE.call
            run_command_and_stop command
            expect(File.read(TEMP_FILE)).not_to be_nil
          end

          context 'decrypt from a redirect' do
            let(:args) { "-d -k #{KEY_PLAIN} -f #{TEMP_FILE}" }

            it 'runs command' do
              expect(File.exist?(TEMP_FILE)).to be true
              expect(output).to eq('hello')
            end
          end
        end
      end
    end
  end
end

