require 'spec_helper'
require 'sym/app/commands/generate_key'
require 'sym'
require 'sym/constants'
require 'sym/application'

RSpec.describe 'CLI execution', type: :aruba do

  let(:base62_regex) { %r{^[a-zA-Z0-9=.\-_]+=$} }
  let(:key_plain) { 'm4G6b7Lb-0bom5l8uxog_cL1x08mvH1ASsv1Svl3UGQ=' }
  let(:encrypted_string) { 'BAhTOh1TeW06OkRhdGE6OldyYXBwZXJTdHJ1Y3QLOhNlbmNyeXB0ZWRfZGF0YSIluUtFV4ibk5B65MTjQMXvphsSi7pKPVXt9B2atfMD7cg6B2l2IhWp0jYYSo0CHrm0gWh57mDPOhBjaXBoZXJfbmFtZSIQQUVTLTI1Ni1DQkM6CXNhbHQwOgx2ZXJzaW9uaQY6DWNvbXByZXNzVA==' }
  let(:tempfile) { "#{Dir.pwd}/temp/sym.test.output" }
  let(:tempdir) { File.dirname(tempfile) }

  let(:save_to_a_tempfile_proc) do
    ->(data = nil) do
      FileUtils.rm_rf(tempdir)
      FileUtils.mkdir_p(tempdir)
      File.open(tempfile, 'w') { |f| f.write(data) } if data
      File.read(tempfile) if File.exist?(tempfile)
    end
  end

  context 'using Aruba framework' do
    let(:command) { "bundle exec exe/sym #{args}" }
    let(:output) { last_command_started.stdout.chomp }

    context 'install bash completion' do
      let(:args) { "-B #{tempfile}" }

      before do
        save_to_a_tempfile_proc["#!/usr/bin/env bash\n"]
        run_command_and_stop command, fail_on_error: true
      end

      it 'should have two files to install' do
        expect(::Sym::Constants::Bash::Config.size).to eq(2)
      end

      it 'should run command' do
        expect(File.exist?(tempfile)).to be(true)
        expect(File.read(tempfile)).to include(::Sym::Constants::Bash::Config[:completion][:script])
        expect(File.read(tempfile)).to include(::Sym::Constants::Bash::Config[:symit][:script])
      end
    end

    context 'while running commands' do
      before { run_command_and_stop command }

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
          expect(output).to match(base62_regex)
        end
      end

      context 'encrypt a string' do
        let(:string) { 'Hello, Dolly!' }
        let(:args) { %Q{-e -k #{key_plain} -s "#{string}"} }
        it 'should run command' do
          expect(output).to match(base62_regex)
        end
        it 'should decrypt back' do
          run_command_and_stop "exe/sym -d -k #{key_plain} -s #{output}"
          expect(last_command_started.stdout.chomp).to eq(string)
        end
      end

      context 'decrypt a string' do
        let(:args) { "-d -k #{key_plain} -s #{encrypted_string}" }
        it 'should run command' do
          expect(output).to eq('hello')
        end
      end

      if Sym::App.is_osx?
        context 'import a key into keychain' do
          let(:args) { "-k #{key_plain} -x MOO" }
          it 'should add to keychain' do
            expect(Sym::App::KeyChain.get('MOO')).to eq(key_plain)
            expect(output).to eq(key_plain)
          end
        end
      end

      context 'import a key into a file' do
        let(:tempfile) { Tempfile.new('sym-rspec') }
        let(:args) { "-k #{key_plain} -o #{tempfile.path}" }
        it 'should add to keychain' do
          expect(File.read(tempfile.path)).to eq(key_plain)
        end
      end

      context 'using a temporary file' do
        context 'encrypt with redirect' do
          let(:args) { %Q[-e -k #{key_plain} -s "hello\n" -o #{tempfile} ] }

          it 'should run command' do
            save_to_a_tempfile_proc.call
            run_command_and_stop command
            expect(File.read(tempfile)).to_not be_nil
          end

          context 'decrypt from a redirect' do
            let(:args) { "-d -k #{key_plain} -f #{tempfile}" }

            it 'should run command' do
              expect(File.exist?(tempfile)).to be true
              expect(output).to eq('hello')
            end
          end
        end
      end
    end
  end
end

