#!/usr/bin/env ruby
require 'slop'
require 'secrets'
require 'colored2'
require 'hashie/mash'
require 'yaml'
require 'openssl'
require 'secrets/errors'
require 'secrets'
module Secrets
  module App
    class CLI
      include Secrets

      attr_accessor :opts, :c, :output, :action

      def initialize(argv)
        self.opts = parse(argv)
        opts_hash = opts.nil? ? {} : opts.to_hash
        self.c    = Hashie::Mash.new(opts_hash)

        write_to_file_proc = ->(data) {
          File.open(c.output, 'w') do |f|
            f.write(data)
          end
          puts "File #{c.file} (#{File.size(c.file)/1024}Kb) has been #{action}ypted and saved to #{c.output} (#{File.size(c.output) / 1024}Kb)" if c.verbose
        }

        print_proc  = ->(argument) { puts argument }
        self.output = c.output ? write_to_file_proc : print_proc
      end

      def run
        return Secrets::App.exit_code if Secrets::App.exit_code != 0
        self.action = { c.encrypt => :encr, c.decrypt => :decr }[true]
        result = if c.help or c.keys.all? { |k| !c[k] }
                   puts opts.to_s
                   nil
                 elsif c.version
                   "secrets-cipher-base64 (version #{Secrets::VERSION})"
                 elsif c.generate
                   self.class.create_private_key
                 elsif c.private_key
                   if c.encrypt && c.decrypt
                     error type: 'Command Line Options Error', details: 'Cannot both encrypt and decrypt, please choose one.'
                   elsif c.encrypt || c.decrypt
                     content = c.string || (c.file.eql?('-') ? STDIN.read : File.read(c.file))
                     self.send(action, content, c.private_key)
                   elsif c.edit
                     'Not yet implemented'
                   end
                 elsif c.examples
                   examples
                 else
                   raise Secrets::Errors::NoPrivateKeyFound.new('Key is required') unless c.private_key
                   puts opts.to_s
                   nil
                 end
        output.call(result) if result
      rescue ::OpenSSL::Cipher::CipherError => e
        error type:      'Cipher Error',
              details:   e.message,
              reason:    'Perhaps either the secret is invalid, or encrypted data is corrupt.',
              exception: e
      rescue Exception => e
        error exception: e
      end

      def error(hash)
        Secrets::App.error(hash.merge(config: c))
      end

      private

      def parse(arguments)
        Slop.parse(arguments) do |o|
          o.banner = 'Usage:'.bold.yellow
          o.separator '    secrets [options]'.bold.green
          o.separator 'Modes:'.bold.yellow
          o.bool      '-h', '--help',       '           show help'
          o.bool      '-e', '--encrypt',    '           encrypt'
          o.bool      '-d', '--decrypt',    '           decrypt'
          o.bool      '-g', '--generate',   '           generate new private key'
          o.separator 'Options:'.bold.yellow
          o.string    '-k', '--private-key','[key]   '.bold.blue + '   specify the encryption key'
          o.string    '-s', '--string',     '[string]'.bold.blue + '   specify a string to encrypt/decrypt'
          o.string    '-f', '--file',       '[file]  '.bold.blue + '   a file to encrypt/decrypt'
          o.string    '-o', '--output',     '[file]  '.bold.blue + '   a file to write to'
          o.separator 'Flags:'.bold.yellow
          o.bool      '-E', '--examples',   '           show usage examples'
          o.bool      '-V', '--version',    '           print the version'
          o.bool      '-v', '--verbose',    '           show additional info'
          o.string    '-t', '--edit',       '[file]  '.bold.blue + '   open an encrypted yaml in an editor'
          o.separator ''
        end
      rescue Exception => e
        error exception: e
        nil
      end

      def examples
        puts 'Examples:'.bold.yellow
        example comment: 'generate a new secret:',
                command: 'export KEY=$(secrets -g)',
                echo:    'echo $KEY',
                output:  '75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4='

        example comment: 'encrypt a plain text string with the key:',
                command: 'export ENCRYPTED=$(secrets -e -s "secret string" -k $KEY)',
                echo:    'echo $ENCRYPTED',
                output:  'Y09MNDUyczU1S0UvelgrLzV0RTYxZz09CkBDMEw4Q0R0TmpnTm9md1QwNUNy%T013PT0K'

        example comment: 'decrypt a previously encrypted string:',
                command: 'secrets -d -s $ENCRYPTED -k $KEY',
                output:  'secret string'

        example comment: 'encrypt a file:',
                command: 'secrets -e -f secrets.yml -o secrets.enc -k $KEY'

        example comment: 'decrypt an encrypted file and print to STDOUT:',
                command: 'secrets -d -f secrets.enc -k $KEY'

      end

      def example(comment: nil, command: nil, echo: nil, output: nil)
        puts
        puts "# #{comment}".black.on.white.italic if comment
        puts "#{command}".bold if command
        puts "#{echo}".bold if echo
        puts output.bold.cyan if output
      end
    end
  end
end
