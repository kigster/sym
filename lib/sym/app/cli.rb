require 'slop'
require 'sym'
require 'colored2'
require 'yaml'
require 'openssl'
require 'highline'

require 'sym/application'
require 'sym/errors'

require 'sym/app/commands'
require 'sym/app/keychain'
require 'sym/app/private_key/handler'

require 'sym/app/output/base'
require 'sym/app/output/file'
require 'sym/app/output/stdout'
require 'sym/app/cli_slop'

module Sym
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
    # options provided is performed by the {Sym::App::PrivateKey::Handler}
    # instance. See there for more details.
    #
    # Subsequently, +#run+ method handles the finding of the appropriate
    # {Sym::App::Commands::BaseCommand} subclass to respond to user's request.
    # Command registry, sorting, command dependencies, and finding them is
    # done by the {Sym::App::Coommands} module.
    #
    # User input is handled by the {Sym::App::Input::Handler} instance, while
    # the output is provided by the procs in the {Sym::App::Output} classes.
    #
    # Finally, the Mac OS-X -specific usage of the KeyChain, is encapsulated
    # in a cross-platform way inside the {Sym::App::Keychain} module.

    class CLI
      # brings in #parse(Array[String] args)
      include CLISlop

      attr_accessor :opts, :application, :outputs, :stdin, :stdout, :stderr, :kernel


      def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = nil)

        self.stdin  = stdin
        self.stdout = stdout
        self.stderr = stderr
        self.kernel = kernel

        Sym::App.stdin  = stdin
        Sym::App.stdout = stdout
        Sym::App.stderr = stderr

        begin
          # Re-map any legacy options to the new options
          self.opts = parse(argv)
          if opts[:sym_args]
            append_sym_args(argv)
            self.opts = parse(argv)
          end

          # Disable coloring if requested, or if piping STDOUT
          if opts[:no_color] || !self.stdout.tty?
            Colored2.disable! # reparse options without the colors to create new help msg
            self.opts = parse(argv)
          end

        rescue StandardError => e
          log :error, "#{e.message}" if opts
          error exception: e
          return
        end

        self.application = ::Sym::Application.new(opts, stdin, stdout, stderr, kernel)
      end

      def append_sym_args(argv)
        if env_args = sym_args
          argv << env_args.split(' ')
          argv.flatten!
          argv.compact!
        end
      end

      def sym_args
        ENV[Sym::Constants::ENV_ARGS_VARIABLE_NAME]
      end

      def execute!
        execute
      end

      def execute
        return Sym::App.exit_code if Sym::App.exit_code != 0
        result = application.execute
        if result.is_a?(Hash)
          self.output_proc ::Sym::App::Args.new({}).output_class
          error(result)
        end
        Sym::App.exit_code
      end

      def command
        @command ||= self.application&.command
      end

      def output_proc(proc = nil)
        if self.application
          self.application.output = proc if proc
          return self.application.output
        end
        nil
      end

      def opts_present
        o = opts.to_hash
        o.keys.map { |k| opts[k] ? nil : k }.compact.each { |k| o.delete(k) }
        o
      end

      private

      def log(*args)
        Sym::App.log(*args, **(opts.to_hash))
      end

      def error(hash)
        hash.merge!(config: opts.to_hash) if opts
        hash.merge!(command: @command) if @command
        Sym::App.error(**hash)
      end

    end
  end
end
