#!/usr/bin/env ruby
require 'slop'
require 'secrets'
require 'colored2'
require 'hashie/mash'
require 'yaml'
require 'openssl'
require 'secrets/errors'
require 'secrets/app/commands'

module Secrets
  module App
    class CLI
      include Secrets

      attr_accessor :opts, :output_proc, :action, :print_proc, :write_to_file_proc

      def initialize(argv)
        self.opts = parse(argv.dup)
        if opts[:no_color]
          Colored2.disable!
          self.opts = parse(argv.dup)
        end
        self.action = { opts[:encrypt] => :encr, opts[:decrypt] => :decr }[true]
        self.write_to_file_proc = ->(data) {
          File.open(opts[:output], 'w') do |f|
            f.write(data)
          end
          puts "File #{opts[:file]} (#{File.size(opts[:file])/1024}Kb) has been #{opts[:action]}ypted and saved to #{opts[:output_proc]} (#{File.size(opts[:output]) / 1024}Kb)" if opts[:verbose]
        }
        self.print_proc  = ->(argument) { puts argument }
        select_output_proc
      end

      def run
        return Secrets::App.exit_code if Secrets::App.exit_code != 0
        command = Secrets::App::Commands.find_command(opts)
        if command
          output_proc.call(command.new(self).run)
        else
          self.output_proc = self.print_proc
          handle_command_not_found
        end
      rescue ::OpenSSL::Cipher::CipherError => e
        error type:      'Cipher Error',
              details:   e.message,
              reason:    'Perhaps either the secret is invalid, or encrypted data is corrupt.',
              exception: e
      rescue Exception => e
        error exception: e
      end

      def error(hash)
        Secrets::App.error(hash.merge(config: opts.to_hash))
      end

      private

      def handle_command_not_found
        if opts[:private_key]
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

      def select_output_proc
        self.output_proc = opts[:output] ? self.write_to_file_proc : self.print_proc
      end

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
          o.bool      '-n', '--no-color',   '           disable color output'
          o.string    '-t', '--edit',       '[file]  '.bold.blue + '   open an encrypted yaml in an editor'
          o.separator ''
        end
      rescue Exception => e
        error exception: e
        nil
      end

    end
  end
end
