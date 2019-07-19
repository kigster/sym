require 'sym'
require 'sym/app'
require 'forwardable'
require 'active_support/inflector'

module Sym
  module App
    module Commands
      class BaseCommand

        def self.inherited(klass)
          klass.instance_eval do
            class << self
              attr_accessor :required, :incompatible

              include Sym::App::ShortName

              def try_after(*dependencies)
                Sym::App::Commands.order(self, dependencies)
              end

              def required_options(*args)
                self.required ||= Set.new
                required.merge(args) if args
                required
              end

              def incompatible_options(*args)
                self.incompatible ||= Set.new
                incompatible.merge(args) if args
                incompatible
              end

              def options_satisfied_by?(opts_hash)
                proc = required_options.find { |option| option.is_a?(Proc) }
                return true if proc && proc.call(opts_hash)
                return false if incompatible_options.any? { |option| opts_hash[option] }
                required_options.to_a.delete_if { |o| o.is_a?(Proc) }.all? { |o|
                  o.is_a?(Array) ? o.any? { |opt| opts_hash[opt] } : opts_hash[o]
                }
              end
            end

            # Register this command with the global list.
            Sym::App::Commands.register klass
          end
        end

        include Sym
        extend Forwardable

        attr_accessor :application
        def_delegators :@application, :opts, :opts_slop, :key, :stdin, :stdout, :stderr, :kernel

        def initialize(application)
          self.application = application
        end

        def execute
          raise Sym::Errors::AbstractMethodCalled.new(:run)
        end

        def content
          @content ||= (opts[:string] || (opts[:file].eql?('-') ? stdin.read : ::File.read(opts[:file]).chomp))
        end

        def to_s
          "#{self.class.short_name.to_s.bold.yellow}, with options: #{application.args.argv.join(' ').gsub(/--/, '').bold.green}"
        end

        def create_key
          self.class.create_private_key
        end

        def add_to_keychain_if_needed(key)
          if opts[:keychain] && Sym::App.osx?
            Sym::App::KeyChain.new(opts[:keychain], opts).add(key)
          else
            key
          end
        end

        def encrypt_with_password(key)
          password = application.input_handler.new_password
          return encr_password(key, password), password
        end


        def add_password_to_the_cache(encrypted_key, password)
          self.application.password_cache[encrypted_key] = password
        end
      end
    end
  end
end
