# frozen_string_literal: true

require 'colored2'
require 'sym'
require 'sym/app'
require 'openssl'
require 'json'

module Sym
  # Main Application controller class for Sym.
  #
  # Accepts a hash with CLI options set (as symbols), for example
  #
  # Example
  # =======
  #
  #     app = Sym::Application.new( encrypt: true, file: '/tmp/secrets.yml', output: '/tmp/secrets.yml.enc')
  #     result = app.execute
  #
  #
  class Application
    attr_accessor :opts,
                  :opts_slop,
                  :args,
                  :argv,
                  :action,
                  :key,
                  :key_source,
                  :input_handler,
                  :key_handler,
                  :output,
                  :result,
                  :password_cache,
                  :stdin, :stdout, :stderr, :kernel

    def initialize(opts, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = nil, _argv = ARGV)
      raise ArgumentError, "opts must not be nil when creating Application!" if opts.nil?

      self.stdin  = stdin
      self.stdout = stdout
      self.stderr = stderr
      self.kernel = kernel

      self.opts_slop = opts.clone
      self.opts      = opts.is_a?(Hash) ? opts : opts.to_h

      process_negated_option(opts[:negate]) if opts[:negate]
      process_edit_option

      self.args = ::Sym::App::Args.new(provided_options)

      initialize_output_stream
      initialize_action
      initialize_data_source
      initialize_password_cache
      initialize_input_handler
    end

    # Main action method — it looksup the command, and executes it, translating
    # various exception conditions into meaningful error messages.
    def execute
      process_output(execute!)
    rescue ::OpenSSL::Cipher::CipherError => e
      { reason: 'Invalid key provided',
        exception: e }
    rescue Sym::Errors::Error => e
      { reason: e.class.name.gsub(/.*::/, '').underscore.humanize.downcase,
        exception: e }
    rescue TypeError => e
      if e.message =~ /marshal/m
        { reason: 'Corrupt source data or invalid/corrupt key provided',
          exception: e }
      else
        { exception: e }
      end
    rescue StandardError => e
      { exception: e }
    end

    def command
      @command_class ||= Sym::App::Commands.find_command_class(opts)
      @command       ||= @command_class.new(self) if @command_class
      @command
    end

    def provided_flags
      provided_flags = provided_options
      provided_flags.delete_if { |_k, v| ![false, true].include?(v) }
      provided_flags.keys
    end

    def provided_value_options
      provided = provided_options(safe: true)
      provided.delete_if { |_k, v| [false, true].include?(v) }
      provided
    end

    def provided_options(**opts)
      provided_opts = self.opts.clone
      provided_opts.delete_if { |_k, v| !v }
      if opts[:safe]
        provided_options.map do |k, v|
          k == :key && [44, 45].include?(v.size) ?
            [k, '[reducted]'] :
            [k, v]
        end.to_h
      else
        provided_opts
      end
    end

    def editor
      editors_to_try.compact.find { |editor| File.exist?(editor) }
    end

    def process_output(result)
      if result.is_a?(Hash)
        result
      else
        output.call(result)
        result
      end
    end

    private

    def execute!
      initialize_key_source
      unless command
        raise Sym::Errors::InsufficientOptionsError,
              " Can not determine what to do from the options: \n " \
              " #{provided_options.inspect.green.bold}\n" \
              "and flags #{provided_flags.to_s.green.bold}"
      end
      log :info, "command located is #{command.class.name.blue.bold}"
      self.result = command.execute.tap do |result|
        log :info, "result is  #{result.nil? ? 'nil' : result[0..10].to_s.blue.bold}..." if opts[:trace]
      end
    end

    def log(*args)
      Sym::App.log(*args, **opts)
    end

    def editors_to_try
      [
        ENV['EDITOR'],
        '/usr/bin/vim',
        '/usr/local/bin/vim',
        '/bin/vim',
        '/sbin/vim',
        '/usr/sbin/vim',
        '/usr/bin/vi',
        '/usr/local/bin/vi',
        '/bin/vi',
        '/sbin/vi'
      ]
    end

    def initialize_output_stream
      output_klass = args.output_class
      unless output_klass&.is_a?(Class)
        raise "Can not determine output type from arguments #{provided_options}"
      end

      self.output = output_klass.new(opts, stdin, stdout, stderr, kernel).output_proc
    end

    def initialize_input_handler(handler = ::Sym::App::Input::Handler.new(stdin, stdout, stderr, kernel))
      self.input_handler = handler
    end

    def initialize_key_handler
      self.key_handler = ::Sym::App::PrivateKey::Handler.new(opts, input_handler, password_cache)
    end

    def initialize_password_cache
      args            = {}
      args[:timeout]  = (opts[:cache_timeout] || ENV['SYM_CACHE_TTL'] || Sym::Configuration.config.password_cache_timeout).to_i
      args[:enabled]  = opts[:cache_passwords]
      args[:verbose]  = opts[:verbose]
      args[:provider] = opts[:cache_provider] if opts[:cache_provider]

      self.password_cache = Sym::App::Password::Cache.instance.configure(args)

      if opts[:cache_passwords] && !password_cache.enabled
        stderr.puts "Warning: password cache is not available.".magenta.bold
        stderr.puts "   Hint: start a local memcached instance to utilize the cache...\n".magenta
      end
    end

    def process_edit_option
      if opts[:edit]&.is_a?(String) && opts[:file].nil?
        opts[:file] = opts[:edit]
        opts[:edit] = true
      end
    end

    def process_negated_option(file)
      opts.delete(:negate)
      opts[:file] = file
      extension   = Sym.config.encrypted_file_extension
      if file.end_with?('.enc')
        opts[:decrypt] = true
        opts[:output]  = file.gsub(/\.#{extension}/, '')
        opts.delete(:output) if opts[:output] == ''
      else
        opts[:encrypt] = true
        opts[:output]  = "#{file}.#{extension}"
      end
    end

    def initialize_action
      self.action = if opts[:encrypt]
                      :encr
                    elsif opts[:decrypt]
                      :decr
                    end
    end

    # If we are encrypting or decrypting, and no data has been provided, check if we
    # should read from STDIN
    def initialize_data_source
      if action && opts[:string].nil? && opts[:file].nil? && !stdin.tty?
        opts[:file] = '-'
      end
    end

    # If no key is provided with command line options, check the default
    # key location (which can be changed via Configuration class).
    # In any case, attempt to initialize the key one way or another.
    def initialize_key_source
      detect_key_source
      if args.require_key? && !key
        log :error, 'Unable to determine the key, which appears to be required with current args'
        raise Sym::Errors::NoPrivateKeyFound, 'Private key is required when ' + (action ? action.to_s + 'ypting' : provided_flags.join(', '))
      end
      log :debug, "initialize_key_source: detected key ends with [...#{(key ? key[-5..-1] : 'nil').bold.magenta}]"
      log :debug, "opts: #{provided_value_options.to_s.green.bold}"
      log :debug, "flags: #{provided_flags.to_s.green.bold}"
    end

    def detect_key_source
      initialize_key_handler
      self.key = key_handler.key
      if key
        self.key_source = key_handler.key_source
        if key_source =~ /^default_file/
          opts[:key] = key
        end
        log :info, "key was detected from source #{key_source.to_s.bold.green}"
      end
    end
  end
end
