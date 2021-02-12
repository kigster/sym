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

      attr_accessor :opts, :application, :outputs, :stdin, :stdout, :stderr, :kernel, :args

      def initialize(argv, stdin = $stdin, stdout = $stdout, stderr = $stderr, kernel = nil)
        self.args   = argv
        self.stdin  = stdin
        self.stdout = stdout
        self.stderr = stderr
        self.kernel = kernel

        Sym::App.stdin  = stdin
        Sym::App.stdout = stdout
        Sym::App.stderr = stderr

        begin
          # Re-map any legacy options to the new options
          self.opts = parse(args)

          if opts[:user_home]
            Constants.user_home = opts[:user_home]
            raise InvalidSymHomeDirectory, "#{opts[:user_home]} does not exist!" unless Dir.exist?(Constants.user_home)
          end

          # Deal with SYM_ARGS and -A
          if opts[:sym_args] && non_empty_array?(sym_args)
              args << sym_args
              args.flatten!
              args.compact!
              args.delete('-A')
              args.delete('--sym-args')
              self.opts = parse(args)
          end

          # Disable coloring if requested, or if piping STDOUT
          if opts[:no_color] || !self.stdout.tty?
            Colored2.disable! # reparse options without the colors to create new help msg
            self.opts = parse(args)
          end

        rescue StandardError => e
          log :error, "#{e.message}" if opts
          error exception: e
          quit!(127) if stdin == $stdin
        end

        self.application = ::Sym::Application.new(self.opts, stdin, stdout, stderr, kernel)
      end

      def quit!(code = 0)
        exit(code)
      end

      def sym_args
        (ENV['SYM_ARGS']&.split(/\s+/) || [])
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
        @command ||= self.application.command if self.application
      end

      def output_proc(proc = nil)
        if self.application
          self.application.output = proc if proc
          return self.application.output
        end
        nil
      end

      def opts_present
        opts.to_hash.tap do |o|
          o.keys.map { |k| opts[k] ? nil : k }.compact.each { |k| o.delete(k) }
        end
      end

      def log(*args)
        Sym::App.log(*args, **opts.to_hash)
      end


      private

      def non_empty_array?(object)
        object.is_a?(Array) && !object.empty?
      end

      def error(hash)
        hash.merge!(config: opts.to_hash) if opts
        hash.merge!(command: @command) if @command
        Sym::App.error(**hash)
      end

    end
  end
end
