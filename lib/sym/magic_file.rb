require 'sym/application'
module Sym
  # This class provides a very simple API for loading/reading encrypted files
  # into memory buffers, while supporting all of the convenience features of the
  # sym CLI.
  #
  # You initialize this class with just two things: a pathname to a file (encrypted
  # or not), and the key identifier. The identifier can either be a filename, or
  # OS-X Keychain entry, or environment variable name, etc — basically it is resolved
  # like any other `-k <value>` CLI flag.
  #
  # == Example
  #
  # In this example, we assume that the environment variable $PRIVATE_KEY contain
  # the key to be used in decryption. Note that methods +decrypt+ and +read+ are
  # synomymous
  #
  #    require 'sym/magic_file'
  #    magic = Sym::MagicFile.new('/usr/local/etc/secrets.yml.enc', 'PRIVATE_KEY')
  #    YAML.load(magic.read)
  #
  # Or, lets say you are using the +config+ gem. Then you would do something like this:
  #
  #    require 'config'
  #    Settings.add_source!(YAML.load(magic.decrypt))
  #
  class MagicFile
    attr_accessor :pathname, :opts, :key_value, :action

    def initialize(pathname, key_value, **opts)
      init(key_value, opts, pathname)
    end

    # Returns decrypted string
    def read
      decrypt
    end

    # Encrypts +pathname+ to a +filename+
    def encrypt_to(filename)
      self.opts.merge!({output: filename})
      encrypt
    end

    # Decrypts +pathname+ to a +filename+
    def decrypt_to(filename)
      self.opts.merge!({output: filename})
      decrypt
    end

    # Returns encrypted string
    def encrypt
      self.opts.merge!({ encrypt: true })
      action
    end

    # Returns decrypted string
    def decrypt
      self.opts.merge!({ decrypt: true })
      action
    end

    private

    def init(key_value, opts, pathname)
      raise ArgumentError, 'pathname does not exist' unless ::File.exist?(pathname)
      self.pathname  = pathname
      self.opts      = opts || {}
      self.key_value = key_value
      self.opts.merge!({ file: pathname, key: key_value, quiet: true})
    end

    def action
      app    = Sym::Application.new(opts)
      result = app.execute
      if result.is_a?(Hash)
        log :error, result.inspect
        raise result[:exception] if result[:exception]
      else
        return result
      end
    end

    def log(*args)
      Sym::App.log(*args, **opts)
    end
  end
end
