#!/usr/bin/env ruby
require 'slop'
require 'secrets'
require 'colored2'
require 'hashie/mash'
require 'yaml'
require 'openssl'

module Secrets
  module App
    class CLI
      include Secrets

      attr_accessor :opts, :c, :output

      def initialize(argv)
        self.opts = parse(argv)
        error type: 'Options Error', details: 'Invalid options provided' if opts.nil?
        self.c      = Hashie::Mash.new((opts || {}).to_hash)
        self.output = ->(argument) { puts argument }
      end

      def run
        action   = { c.encrypt => :encrypt, c.decrypt => :decrypt }[true]
        result = if c.help or c.keys.all? { |k| !c[k] }
                   opts.to_s
                 elsif c.version
                   "secrets-cipher-base64 (version #{Secrets::VERSION})"
                 elsif c.generate
                   self.class.create_secret
                 elsif c.secret
                   if c.encrypt && c.decrypt
                     error type: 'Command Line Options Error', details: 'Cannot both encrypt and decrypt, please choose one.'
                   elsif c.encrypt || c.decrypt
                     if c.phrase
                       Secrets::Encrypted::ScalarData.new(c.phrase).send(action, c.secret)
                     elsif c.yaml
                       contents = c.yaml.eql?('-') ? STDIN.read : File.read(c.yaml)
                       e_hash   = Secrets::Encrypted::HashData.new(YAML.load(contents))
                       puts e_hash.send(action, c.secret).to_hash.to_yaml
                     end
                   elsif c.open
                     'Not yet implemented'
                   end
                 elsif c.examples
                   examples
                 else
                   opts.to_s
                 end
        output.call(result)
      rescue ::OpenSSL::Cipher::CipherError => e
        error type:    'Cipher Error',
              details: e.message,
              reason:  'Perhaps either the secret is invalid, or encrypted data is corrupt.',
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
          o.bool '-h', '--help', '           show help'
          o.bool '-e', '--encrypt', '           encrypt'
          o.bool '-d', '--decrypt', '           decrypt'
          o.bool '-g', '--generate', '           generate new secret'
          o.separator 'Options:'.bold.yellow
          o.string '-s', '--secret', '[secret]'.bold.blue + '   specify a secret'
          o.string '-p', '--phrase', '[string]'.bold.blue + '   specify a string to encrypt/decrypt'
          o.string '-y', '--yaml', '[file]  '.bold.blue + '   yaml file to encrypt/decrypt'
          o.separator 'Flags:'.bold.yellow
          o.bool '-E', '--examples', '           show usage examples'
          o.bool '-V', '--version', '           print the version'
          o.bool '-v', '--verbose', '           show additional info'
          o.string '-o', '--open', '[file]  '.bold.blue + '   open an encrypted yaml in an editor'
          o.separator ''
        end
      rescue Exception => e

      end

      def examples
        puts 'Examples:'.bold.yellow
        example comment: 'generate a new secret:',
                command: 'export SECRET=$(secrets -g)',
                echo:    'echo $SECRET',
                output:  '75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4='

        example comment: 'encrypt a plain text string with the secret:',
                command: 'export ENCRYPTED=$(secrets -e -p "secret string" -s $SECRET)',
                echo:    'echo $ENCRYPTED',
                output:  'Y09MNDUyczU1S0UvelgrLzV0RTYxZz09CkBDMEw4Q0R0TmpnTm9md1QwNUNy%T013PT0K%'

        example comment: 'decrypt a previously encrypted phrase:',
                command: 'secrets -d -p $ENCRYPTED -s $SECRET',
                output:  'secret string'
      end

      def example(comment: nil, command: nil, echo: nil, output: nil)
        puts
        p = '> '
        puts "# #{comment}".black.on.white.italic if comment
        puts "#{p}#{command}".bold if command
        puts "#{p}#{echo}".bold if echo
        puts output.bold.cyan if output
      end
    end
  end
end
