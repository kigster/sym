require 'colored2'
require 'sym'
require 'sym/app'
require 'openssl'

module Sym
  class Application

    attr_accessor :opts,
                  :opts_hash,
                  :args,
                  :action,
                  :key,
                  :input_handler,
                  :key_handler,
                  :result,
                  :password_cache

    def initialize(opts)
      self.opts      = opts
      self.opts_hash = opts.respond_to?(:to_hash) ? opts.to_hash : opts
      self.args      = ::Sym::App::Args.new(opts_hash)

      initialize_password_cache
      initialize_input_handler
      initialize_key_handler
      initialize_action
    end

    def initialize_action
      self.action = if opts[:encrypt] then
                      :encr
                    elsif opts[:decrypt]
                      :decr
                    end
    end

    def execute!
      if !args.generate_key? && (args.require_key? || args.specify_key?)
        log :debug, 'operation requires a key...'
        self.key = Sym::App::PrivateKey::Handler.new(opts, input_handler, password_cache).key
        unless self.key
          log :error, 'Unable to determine the key, which appears to be required'
          raise Sym::Errors::NoPrivateKeyFound, 'Private key is required'
        end
      end
      log :info, "detected command [#{command.class.name}]"
      unless command
        raise Sym::Errors::InsufficientOptionsError, 'Can not determine what to do from the options ' + opts_hash.keys.reject { |k| !opts[k] }.to_s
      end
      self.result = command.execute
    end

    def log(*args)
      Sym::App.log(*args, **opts)
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
      if e.message =~ /marshal/
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

    def editor
      editors_to_try.find { |editor| File.exist?(editor) }
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

    def initialize_input_handler(handler = ::Sym::App::Input::Handler.new)
      self.input_handler = handler
    end

    def initialize_key_handler
      self.key_handler = ::Sym::App::PrivateKey::Handler.new(self.opts, input_handler, password_cache)
    end

    def initialize_password_cache
      args            = {}
      args[:timeout]  = opts[:cache_for].to_i if opts[:cache_for]
      args[:enabled]  = opts[:cache_password]
      args[:verbose]  = opts[:verbose]
      args[:provider] = opts[:cache_provider] if opts[:cache_provider]

      self.password_cache = Sym::App::Password::Cache.instance.configure(args)
    end
  end
end
