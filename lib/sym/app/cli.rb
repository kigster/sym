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

      attr_accessor :opts, :application, :outputs, :output_proc

      def initialize(argv)
        begin
          argv << args_from_environment(argv)
          argv.flatten!
          argv.compact!
          argv_original = argv.dup
          # Re-map any leg  acy options to the new options
          argv = CLI.replace_argv(argv)
          dict      = argv.delete('--dictionary')
          self.opts = parse(argv)
          command_dictionary if dict
        rescue StandardError => e
          error exception: e
          return
        end

        # Disable coloring if requested, or if piping STDOUT
        if opts[:no_color] || !STDOUT.tty?
          command_no_color(argv_original)
        end

        self.application = ::Sym::Application.new(opts)
        select_output_stream
      end

      def args_from_environment(argv)
        env_args = ENV[Sym::Constants::ENV_ARGS_VARIABLE_NAME]
        if env_args && !(argv.include?('-M') or argv.include?('--no-environment'))
          env_args.split(' ')
        else
          []
        end
      end

      def execute
        return Sym::App.exit_code if Sym::App.exit_code != 0
        result = application.execute
        case result
          when Hash
            self.output_proc = ::Sym::App::Args.new({}).output_class
            error(result)
          else
            self.output_proc.call(result)
        end
        Sym::App.exit_code
      end

      def command
        @command ||= self.application&.command
      end

      def opts_present
        o = opts.to_hash
        o.keys.map { |k| opts[k] ? nil : k }.compact.each { |k| o.delete(k) }
        o
      end

      class << self
        # Re-map any legacy options to the new options
        ARGV_FLAG_REPLACE_MAP = {
          'C' => 'c'
        }

        def replace_regex(from)
          %r{^-([\w]*)#{from}([\w]*)$}
        end

        def replace_argv(argv)
          argv = argv.dup
          replacements = []
          ARGV_FLAG_REPLACE_MAP.each_pair do |from, to|
            argv.map! do |a|
              match = replace_regex(from).match(a)
              if match
                replacements << from
                "-#{match[1]}#{to}#{match[2]}"
              else
                a
              end
            end
          end
          argv
        end
      end

      private

      def command_dictionary
        options = opts.parser.unused_options + opts.parser.used_options
        puts options.map(&:to_s).sort.map { |o| "-#{o[1]}" }.join(' ')
        exit 0
      end

      def error(hash)
        hash.merge!(config: opts.to_hash) if opts
        hash.merge!(command: @command) if @command
        Sym::App.error(**hash)
      end

      def select_output_stream
        output_klass = application.args.output_class
        unless output_klass && output_klass.is_a?(Class)
          raise "Can not determine output class from arguments #{opts.to_hash}"
        end
        self.output_proc = output_klass.new(application.opts).output_proc
      end

      def command_no_color(argv)
        Colored2.disable! # reparse options without the colors to create new help msg
        self.opts = parse(argv.dup)
      end

      def key_spec
        '<key-spec>'.bold.magenta
      end
    end
  end
end
