require 'colored2'
require 'sym'
require 'sym/app'
require 'openssl'

module Sym
  class Application

    attr_accessor :opts,
                  :opts_hash,
                  :provided_options,
                  :args,
                  :action,
                  :key,
                  :key_source,
                  :input_handler,
                  :key_handler,
                  :result,
                  :password_cache

    def initialize(opts)
      self.opts             = opts
      self.opts_hash        = opts.respond_to?(:to_hash) ? opts.to_hash : opts
      self.provided_options = opts_hash.keys.select { |k| opts_hash[k] }
      self.args             = ::Sym::App::Args.new(opts_hash)

      initialize_action
      initialize_data_source
      initialize_password_cache
      initialize_input_handler
    end

    def execute!
      initialize_key_source
      unless command
        raise Sym::Errors::InsufficientOptionsError,
              'Can not determine what to do from the options:\\n' + args.provided_options.inspect.green.bold
      end
      log :info, "execute! command is #{command.class.name.blue.bold}"
      self.result = command.execute.tap do |result|
        log :info, "execute! result is  #{result.nil? ? 'nil' : result[0..40].to_s.blue.bold }..."
      end
    end

    def execute
      execute!
    rescue ::OpenSSL::Cipher::CipherError => e
      { reason:    'Invalid key provided',
        exception: e }

    rescue Sym::Errors::Error => e
      { reason:    e.class.name.gsub(/.*::/, '').underscore.humanize.downcase,
        exception: e }

    rescue TypeError => e
      if e.message =~ /marshal/m
        { reason:    'Corrupt source data or invalid/corrupt key provided',
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

    def log(*args)
      Sym::App.log(*args, **opts)
    end

    def editor
      editors_to_try.find { |editor| File.exist?(editor) }
    end


    private

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

    def initialize_input_handler(handler = ::Sym::App::Input::Handler.new)
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
    end


    def initialize_action
      self.action = if opts[:encrypt] then
                      :encr
                    elsif opts[:decrypt]
                      :decr
                    end
    end

    # If we are encrypting or decrypting, and no data has been provided, check if we
    # should read from STDIN
    def initialize_data_source
      if self.action && opts[:string].nil? && opts[:file].nil? && !(STDIN.tty?)
        opts[:file] = '-'
      end
    end

    # If no key is provided with command line options, check the default
    # key location (which can be changed via Configuration class).
    # In any case, attempt to initialize the key one way or another.
    def initialize_key_source
      detect_key_source

      if args.require_key? && !self.key
        log :error, 'Unable to determine the key, which appears to be required with current args'
        raise Sym::Errors::NoPrivateKeyFound, 'Private key is required when ' + (::Sym::App::Args::OPTIONS_REQUIRE_KEY & provided_options).join(', ') << 'ing.'
      end

      log :debug, "initialize_key_source: detected key is [#{key ? key : 'nil'}]"
    end

    def detect_key_source
      initialize_key_handler
      self.key = self.key_handler.key
      if self.key
        self.key_source = key_handler.key_source
        if key_source =~ /^default_file/
          opts[:key] = self.key
        end
        log :info, "key was detected from source #{key_source.to_s.bold.green}"
      end
    end
  end
end
