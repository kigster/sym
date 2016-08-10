 #!/usr/bin/env ruby
require 'slop'
require 'secrets'
require 'colored2'
require 'yaml'
require 'openssl'
require 'secrets/app'
require 'secrets/errors'
require 'secrets/app/commands'
require 'secrets/app/keychain'
require 'highline'

require_relative 'outputs/to_file'
require_relative 'outputs/to_stdout'

module Secrets
  module App
    class CLI
      include Secrets

      attr_accessor :opts,
                    :output_proc,
                    :action,
                    :print_proc,
                    :write_proc,
                    :password,
                    :key

      def initialize(argv)
        begin
          self.opts = parse(argv.dup)
        rescue StandardError => e
          error exception: e
          return
        end
        configure_color(argv)
        define_output
        self.action = { opts[:encrypt] => :encr, opts[:decrypt] => :decr }[true]
      end

      def command
        @command_class ||= Secrets::App::Commands.find_command_class(opts)
        @command       ||= @command_class.new(self) if @command_class
      end

      def run
        return Secrets::App.exit_code if Secrets::App.exit_code != 0

        define_private_key
        decrypt_private_key if should_decrypt_private_key?
        verify_private_key_encoding if key

        if command
          return self.output_proc.call(command.run)
        else
          # command was not found. Reset output to printing, and return an error.
          self.output_proc = print_proc
          command_not_found_error!
        end

      rescue ::OpenSSL::Cipher::CipherError => e
        error type:      'Cipher Error',
              details:   e.message,
              reason:    'Perhaps either the secret is invalid, or encrypted data is corrupt.',
              exception: e

      rescue Secrets::Errors::InvalidEncodingPrivateKey => e
        error type:      'Private Key Error',
              details:   'Private key does not appear to be properly encoded. ',
              reason:    (opts[:password] ? nil : 'Perhaps the key is password-protected?'),
              exception: e

      rescue Secrets::Errors::Error => e
        error type:      'Error',
              details:   e.message,
              exception: e

      rescue StandardError => e
        error exception: e
      end

      def error(hash)
        Secrets::App.error(hash.merge(config: (opts ? opts.to_hash : {})))
      end

      def editor
        ENV['EDITOR'] || '/bin/vi'
      end

      private

      def should_decrypt_private_key?
        key && (key.length > 45 || opts[:password])
      end

      def define_output
        self.print_proc  = Secrets::App::Outputs::ToStdout.new(self).output_proc
        self.write_proc  = Secrets::App::Outputs::ToFile.new(self).output_proc
        self.output_proc = opts[:output] ? self.write_proc : self.print_proc
      end

      def define_private_key
        begin
          opts[:private_key] = File.read(opts[:key_file]) if opts[:key_file]
        rescue Errno::ENOENT
          raise Secrets::Errors::FileNotFound.new("Encryption key file #{opts[:key_file]} was not found.")
        end

        opts[:private_key] ||= PasswordHandler.handle_user_input('Private Key: ', :magenta) if opts[:interactive]
        opts[:private_key] ||= KeyChain.new(opts[:keychain]).find if opts[:keychain]
        self.key           = opts[:private_key]
      end

      def configure_color(argv)
        if opts[:no_color]
          Colored2.disable! # reparse options without the colors to create new help msg
          self.opts = parse(argv.dup)
        end
      end

      def verify_private_key_encoding
        begin
          Base64.urlsafe_decode64(key)
        rescue ArgumentError => e
          raise Secrets::Errors::InvalidEncodingPrivateKey.new(e)
        end
      end

      def decrypt_private_key
        handler = Secrets::App::PasswordHandler.new(opts)
        decrypted_key = nil
        begin
          retries ||= 0
          handler.ask
          decrypted_key = decr_password(key, handler.password)
        rescue ::OpenSSL::Cipher::CipherError => e
          STDERR.puts 'Invalid password. Please try again.'
          ((retries += 1) < 3) ? retry : raise(Secrets::Errors::InvalidPasswordPrivateKey.new(e))
        end
        self.key = decrypted_key
      end

      def command_not_found_error!
        if key
          h             = opts.to_hash
          supplied_opts = h.keys.select { |k| h[k] }.join(', ')
          error type:    'Options Error',
                details: 'Unable to determined what command to run',
                reason:  "You provided the following options: #{supplied_opts.bold.yellow}"
          output_proc.call(opts.to_s)
        else
          raise Secrets::Errors::NoPrivateKeyFound.new('Private key is required')
        end
      end

      def parse(arguments)
        Slop.parse(arguments) do |o|
          o.banner = 'Usage:'.bold.yellow
          o.separator '    secrets [options]'.bold.green
          o.separator 'Modes:'.bold.yellow
          o.bool      '-h', '--help',         '           show help'
          o.bool      '-d', '--decrypt',      '           decrypt mode'
          o.bool      '-t', '--edit',         '           decrypt, open an encr. file in ' + editor
          o.separator 'Create a private key:'.bold.yellow
          o.bool      '-g', '--generate',     '           generate a new private key'
          o.bool      '-p', '--password',     '           encrypt the key with a password'
          o.bool      '-c', '--copy',         '           copy the new key to the clipboard'
          o.separator 'Provide a private key:'.bold.yellow
          o.bool      '-i', '--interactive',  '           Paste or type the key interactively'
          o.string    '-k', '--private-key',  '[key]   '.bold.blue + '   private key as a string'
          o.string    '-K', '--key-file',     '[key-file]'.bold.blue + ' private key from a file'
          if Secrets::App.is_osx?
          o.string    '-x', '--keychain',     '[key-name] '.bold.blue + 'private key to/from a password entry'
          o.string    '-X', '--keychain-del', '[key-name] '.bold.blue + 'delete keychain entry with that name'
          end
          o.separator 'Data:'.bold.yellow
          o.string    '-s', '--string',       '[string]'.bold.blue + '   specify a string to encrypt/decrypt'
          o.string    '-f', '--file',         '[file]  '.bold.blue + '   filename to read from'
          o.string    '-o', '--output',       '[file]  '.bold.blue + '   filename to write to'
          o.bool      '-b', '--backup',       '           create a backup file in the edit mode'
          o.separator 'Flags:'.bold.yellow
          o.bool      '-v', '--verbose',      '           show additional information'
          o.bool      '-T', '--trace',        '           print a backtrace of any errors'
          o.bool      '-E', '--examples',     '           show several examples'
          o.bool      '-V', '--version',      '           print library version'
          o.bool      '-N', '--no-color',     '           disable color output'
          o.bool      '-e', '--encrypt',      '           encrypt mode'
          o.separator ''
        end
      rescue StandardError => e
        error exception: e
        raise(e)
      end

    end
  end
end
