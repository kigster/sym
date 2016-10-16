require 'colored2'
require 'shhh'
require_dir 'shhh/app'

module Shhh
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
      self.args      = ::Shhh::App::Args.new(opts_hash)

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
      if args.do_options_require_key? || args.do_options_specify_key?
        self.key = Shhh::App::PrivateKey::Handler.new(opts, input_handler, password_cache).key
        raise Shhh::Errors::NoPrivateKeyFound.new('Private key is required') unless self.key
      end

      unless command
        raise Shhh::Errors::InsufficientOptionsError.new(
          'Can not determine what to do from the options ' + opts_hash.keys.reject { |k| !opts[k] }.to_s)
      end
      self.result = command.execute
    end

    def execute
      execute!

    rescue ::OpenSSL::Cipher::CipherError => e
      error type:      'Cipher Error',
            details:   e.message,
            reason:    'Perhaps either the secret is invalid, or encrypted data is corrupt.',
            exception: e

    rescue Shhh::Errors::Error => e
      error type:    e.class.name.split(/::/)[-1],
            details: e.message

    rescue StandardError => e
      error exception: e
    end

    def command
      @command_class ||= Shhh::App::Commands.find_command_class(opts)
      @command       ||= @command_class.new(self) if @command_class
      @command
    end

    def editor
      ENV['EDITOR'] || '/bin/vi'
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

    def error(hash)
      hash
    end

    def initialize_input_handler(handler = ::Shhh::App::Input::Handler.new)
      self.input_handler = handler
    end

    def initialize_key_handler
      self.key_handler = ::Shhh::App::PrivateKey::Handler.new(self.opts, input_handler, password_cache)
    end

    def initialize_password_cache
      password_timeout = opts[:password_timeout] || 300
      cache_enabled    = opts[:no_password_cache] ? false : true

      self.password_cache = Shhh::App::Password::Cache.instance.configure(
        provider: Coin,
        timeout:  password_timeout,
        enabled:  cache_enabled)
    end
  end
end
