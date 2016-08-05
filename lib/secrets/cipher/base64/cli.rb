#!/usr/bin/env ruby
require 'slop'
require 'hashie/mash'
require 'secrets/cipher/base64'
require 'secrets/cipher/base64/encrypted_data'
require 'yaml'
module Secrets
  module Cipher
    module Base64
      class CLI
        attr_accessor :opts, :config, :output

        include Secrets::Cipher::Base64

        def initialize(argv)
          self.opts = parse(argv)
          if opts.nil?
            error type: 'Options Error', details: 'Invalid options provided'
            exit 1
          end
          self.config = Hashie::Mash.new((opts || {}).to_hash)
          self.output = ->(argument) { puts argument }
        end

        def run
          result = if config.help or config.keys.all? { |k| !config[k]}
                     opts.to_s
                   elsif config.version
                     "secrets-cipher-base64 (version #{Secrets::Cipher::Base64::VERSION})"
                   elsif config.generate
                     self.class.create_secret
                   elsif config.secret && config.phrase && (config.encrypt || config.decrypt)
                     encrypted = config.decrypt ? config.phrase : nil
                     decrypted = config.encrypt ? config.phrase : nil
                     accessor  = :decrypted if encrypted
                     accessor  = :encrypted if decrypted
                     raise ArgumentError.new('Can not both decrypt and encrypt, yo!') if encrypted && decrypted
                     EncryptedData.new(
                       encrypted: encrypted,
                       decrypted: decrypted,
                       secret:    config.secret
                     ).send(accessor)
                   elsif config.secret && config.yaml
                     contents = config.yaml.eql?('-') ? STDIN.read : File.read(config.yaml)
                     e_hash = EncryptedHash.new(YAML.load(contents))
                     action = { config.encrypt => :encrypt, config.decrypt => :decrypt }[true]
                     puts e_hash.send(action, config.secret).to_hash.to_yaml
                   else
                     opts.to_s
                   end
          output.call(result)
        rescue OpenSSL::Cipher::CipherError => e
          error type: 'Cipher Error',
                details: e.message,
                reason: 'Perhaps either the secret is invalid, or encrypted data is corrupt.'
        rescue Exception => e
          error type: 'Error',
                details: e.message
        end

        def error(type: 'General Error', details:, reason: nil)
          STDERR.puts "#{type}\n".red.bold.underlined
          STDERR.puts " Details: #{details.red.bold}"
          STDERR.puts "  Reason: #{reason.yellow.bold}" if reason
          STDERR.puts
        end

        private

        def parse(arguments)
          Slop.parse(arguments) do |o|
            o.banner = 'Usage: secrets [options]'
            o.separator ''
            o.separator 'Examples:'
            o.separator '  # generate a new secret:'.yellow
            o.separator '  > export SECRET=$(secrets -g)'.bold.green
            o.separator '  > echo $SECRET'.bold.green
            o.separator '  75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4='.bold.blue
            o.separator ''
            o.separator '  # encrypt a plain text string with the secret:'.yellow
            o.separator '  > export ENCRYPTED=$(secrets -e -p "secret string" -s $SECRET)'.bold.green
            o.separator '  > echo $ENCRYPTED'.bold.green
            o.separator '  Y09MNDUyczU1S0UvelgrLzV0RTYxZz09CkBDMEw4Q0R0TmpnTm9md1QwNUNy%T013PT0K%'.bold.blue
            o.separator ''
            o.separator '  # decrypt a previously encrypted phrase:'.yellow
            o.separator '  > secrets -d -p $ENCRYPTED -s $SECRET'.bold.green
            o.separator '  secret string'.bold.blue

            o.separator ''
            o.separator 'Options:'
            o.string    '-s', '--secret',      '[secret] specify a secret'
            o.string    '-p', '--phrase',      '[string] specify a string to encrypt/decrypt'
            o.string    '-y', '--yaml',        '[file]   yaml file to encr/decr; use "-" for STDIN/OUT'
            o.separator 'Modes:'
            o.bool      '-e', '--encrypt',     '         encrypt'
            o.bool      '-d', '--decrypt',     '         decrypt'
            o.bool      '-g', '--generate',    '         generate new secret'
            o.bool      '-h', '--help',        '         show help'
            o.separator 'Flags:'
            o.bool      '-v', '--verbose',     '         show additional info'
            o.bool      '-V', '--version',     '         print the version'
          end
        rescue Exception => e

        end
      end
    end
  end
end
