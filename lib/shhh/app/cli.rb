require 'slop'
require 'shhh'
require 'colored2'
require 'yaml'
require 'forwardable'
require 'openssl'
require 'shhh/application'
require 'shhh/errors'
require 'shhh/app/commands'
require 'shhh/app/keychain'
require 'shhh/app/private_key/handler'
require 'shhh/app/nlp/constants'
require 'highline'

require_relative 'output/file'
require_relative 'output/file'
require_relative 'output/stdout'

module Shhh
  module App
    # This is the main interface class for the CLI application.
    # It is responsible for parsing user's input, providing help, examples,
    # coordination of various sub-systems (such as PrivateKey detection), etc.
    #
    # Besides holding the majority of the application state, it contains
    # two primary public methods: +#new+ and +#run+.
    #
    # The constructor is responsible for parsing the flags and determining
    # the the application is about to do. It sets up input/output, but doesn't
    # really execute any encryption or decryption. This happens in the +#run+
    # method called immediately after +#new+.
    #
    # {{Shh::App::CLI}} module effectively performs the translation of
    # the +opts+ object (of type {Slop::Result}) and interpretation of
    # users intentions. It holds on to +opts+ for the duration of the program.
    #
    # == Responsibility Delegated
    #
    # The responsibility of determining the private key from various
    # options provided is performed by the {Shhh::App::PrivateKey::Handler}
    # instance. See there for more details.
    #
    # Subsequently, +#run+ method handles the finding of the appropriate
    # {Shhh::App::Commands::Command} subclass to respond to user's request.
    # Command registry, sorting, command dependencies, and finding them is
    # done by the {Shhh::App::Coommands} module.
    #
    # User input is handled by the {Shhh::App::Input::Handler} instance, while
    # the output is provided by the procs in the {Shhh::App::Output} classes.
    #
    # Finally, the Mac OS-X -specific usage of the KeyChain, is encapsulated
    # in a cross-platform way inside the {Shhh::App::Keychain} module.

    class CLI

      extend Forwardable

      def_delegators :@application, :command

      attr_accessor :opts, :application, :outputs, :output_proc

      def initialize(argv)
        begin
          self.opts = parse(argv.dup)
        rescue StandardError => e
          error exception: e
          return
        end

        self.application = ::Shhh::Application.new(opts)

        configure_color(argv)
        select_output_stream

      end

      def execute
        return Shhh::App.exit_code if Shhh::App.exit_code != 0

        result = application.execute
        if result.is_a?(Hash)
          self.output_proc = ::Shhh::App::Args.new({}).output_class
          error(result)
        else
          self.output_proc.call(result)
        end
      end

      private

      def error(hash)
        Shhh::App.error(hash.merge(config: (opts ? opts.to_hash : {})))
      end

      def select_output_stream
        output_klass = application.args.output_class

        unless output_klass && output_klass.is_a?(Class)
          raise "Can not determine output class from arguments #{opts.to_hash}"
        end

        self.output_proc = output_klass.new(self).output_proc
      end

      def configure_color(argv)
        if opts[:no_color]
          Colored2.disable! # reparse options without the colors to create new help msg
          self.opts = parse(argv.dup)
        end
      end

      def parse(arguments)
        Slop.parse(arguments) do |o|
          o.banner = 'Usage:'.bold.yellow
          o.separator '    shhh [options]'.green
          o.separator ' '
          o.separator 'Modes:'.yellow
          o.bool '-h', '--help', '           show help'
          o.bool '-d', '--decrypt', '           decrypt mode'
          o.bool '-t', '--edit', '           decrypt, open an encr. file in an $EDITOR'
          o.separator ' '
          o.separator 'Create a private key:'.yellow
          o.bool '-g', '--generate', '           generate a new private key'
          o.bool '-p', '--password', '           encrypt the key with a password'
          o.bool '-c', '--copy', '           copy the new key to the clipboard'
          o.separator ' '
          o.separator 'Provide a private key:'.yellow
          o.bool '-i', '--interactive', '           Paste or type the key interactively'
          o.string '-k', '--private-key', '[key]   '.blue + '   private key as a string'
          o.string '-K', '--keyfile', '[key-file]'.blue + ' private key from a file'
          if Shhh::App.is_osx?
            o.separator ' '
            o.separator 'Use your KeyChain password entry to store a private key:'.yellow
            o.string '-x', '--keychain', '[key-name] '.blue + 'add to, or read the key from Keychain'
            o.string '--keychain-del', '[key-name] '.blue + 'delete keychain entry with that name'
          end
          o.separator ' '
          o.separator 'Data:'.yellow
          o.string '-s', '--string', '[string]'.blue + '   specify a string to encrypt/decrypt'
          o.string '-f', '--file', '[file]  '.blue + '   filename to read from'
          o.string '-o', '--output', '[file]  '.blue + '   filename to write to'
          o.bool '-b', '--backup', '           create a backup file in the edit mode'
          o.separator ' '
          o.separator 'Flags:'.bold.yellow
          o.bool '-v', '--verbose', '           show additional information'
          o.bool '-q', '--quiet', '           silence all output'
          o.bool '-T', '--trace', '           print a backtrace of any errors'
          o.bool '-E', '--examples', '           show several examples'
          o.bool '-L', '--language', '           natural language examples'
          o.bool '-V', '--version', '           print library version'
          o.bool '-N', '--no-color', '           disable color output'
          o.bool '-e', '--encrypt', '           encrypt mode'
          o.separator ''
          o.on '--dictionary' do
            puts o.to_a.map { |w| "#{w.flags.reject { |f| f.to_s !~ /--/ }.first.to_s}" }.join(' ')
            exit 0
          end
        end
      rescue StandardError => e
        raise(e)
      end
    end
  end
end
