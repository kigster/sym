#!/usr/bin/env ruby
require 'slop'
require 'hashie/mash'
require 'secrets/cipher/base64'
require 'secrets/cipher/base64/encrypted_data'

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
            o.banner = 'Usage: secrets [ -g | [ -e | -d  -s secret -p phrase ]] [-v] [-V] [-h] '
            o.separator ''
            o.separator 'Examples:'
            o.separator '  # generate a new secret:'
            o.separator '  export SECRET=$(secrets -g)'.bold.green
            o.separator ''
            o.separator '  # encrypt a plain text string with the secret:'
            o.separator '  export ENCRYPTED=$(secrets -e -p "secret string" -s $SECRET)'.bold.green
            o.separator ''
            o.separator '  # decrypt a previously encrypted phrase:'
            o.separator '  secrets -d $ENCRYPTED -s $SECRET'.bold.green
            o.separator '  # should print "secret string"'

            o.separator ''
            o.separator 'Options:'
            o.string    '-s', '--secret',      '[secret] specify a secret'
            o.string    '-p', '--phrase',      '[string] specify a string to encrypt/decrypt'
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
