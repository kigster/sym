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
require 'secrets/app/private_key/handler'
require 'highline'

require_relative 'output/file'
require_relative 'output/stdout'

module Secrets
  module App
    class CLI

      attr_accessor :opts, :output_proc, :print_proc, :write_proc,
                    :action, :password, :key

      def initialize(argv)
        begin
          self.opts = parse(argv.dup)
        rescue StandardError => e
          error exception: e
          return
        end
        configure_color(argv)
        select_output_stream
        self.action = { opts[:encrypt] => :encr, opts[:decrypt] => :decr }[true]
        unless opts[:generate]
          self.key = PrivateKey::Handler.new(opts).key
        end
      end

      def run
        return Secrets::App.exit_code if Secrets::App.exit_code != 0

        return self.output_proc.call(command.run) if command

        # command was not found. Reset output to printing, and return an error.
        self.output_proc = print_proc
        command_not_found_error!

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

      def command
        @command_class ||= Secrets::App::Commands.find_command_class(opts)
        @command       ||= @command_class.new(self) if @command_class
      end

      private

      def select_output_stream
        self.print_proc  = Secrets::App::Output::Stdout.new(self).output_proc
        self.write_proc  = Secrets::App::Output::File.new(self).output_proc
        self.output_proc = opts[:output] ? self.write_proc : self.print_proc
      end


      def configure_color(argv)
        if opts[:no_color]
          Colored2.disable! # reparse options without the colors to create new help msg
          self.opts = parse(argv.dup)
        end
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
          o.bool '-h', '--help', '           show help'
          o.bool '-d', '--decrypt', '           decrypt mode'
          o.bool '-t', '--edit', '           decrypt, open an encr. file in ' + editor
          o.separator 'Create a private key:'.bold.yellow
          o.bool '-g', '--generate', '           generate a new private key'
          o.bool '-p', '--password', '           encrypt the key with a password'
          o.bool '-c', '--copy', '           copy the new key to the clipboard'
          o.separator 'Provide a private key:'.bold.yellow
          o.bool '-i', '--interactive', '           Paste or type the key interactively'
          o.string '-k', '--private-key', '[key]   '.bold.blue + '   private key as a string'
          o.string '-K', '--keyfile', '[key-file]'.bold.blue + ' private key from a file'
          if Secrets::App.is_osx?
            o.string '-x', '--keychain', '[key-name] '.bold.blue + 'private key to/from a password entry'
            o.string '--keychain-del', '[key-name] '.bold.blue + 'delete keychain entry with that name'
          end
          o.separator 'Data:'.bold.yellow
          o.string '-s', '--string', '[string]'.bold.blue + '   specify a string to encrypt/decrypt'
          o.string '-f', '--file', '[file]  '.bold.blue + '   filename to read from'
          o.string '-o', '--output', '[file]  '.bold.blue + '   filename to write to'
          o.bool '-b', '--backup', '           create a backup file in the edit mode'
          o.separator 'Flags:'.bold.yellow
          o.bool '-v', '--verbose', '           show additional information'
          o.bool '-T', '--trace', '           print a backtrace of any errors'
          o.bool '-E', '--examples', '           show several examples'
          o.bool '-V', '--version', '           print library version'
          o.bool '-N', '--no-color', '           disable color output'
          o.bool '-e', '--encrypt', '           encrypt mode'
          o.separator ''
        end
      rescue StandardError => e
        error exception: e
        raise(e)
      end
    end
  end
end
