require 'active_support/inflector'
module Secrets
  module App
    module Commands
      class Command

        def self.inherited(klass)
          klass.instance_eval do
            @required_options = Set.new
            class << self
              def required_options(*args)
                @required_options.merge(args) if args
                @required_options
              end

              def short_name
                name.split(/::/)[-1].underscore
              end

              def options_satisfied_by?(opts_hash)
                proc = required_options.find { |option| option.is_a?(Proc) }
                return true if proc && proc.call(opts_hash)

                required_options.to_a.delete_if { |o| o.is_a?(Proc) }.all? { |o|
                  o.is_a?(Array) ? o.any? { |opt| opts_hash[opt] } : opts_hash[o]
                }
              end
            end
            # Register this command with the global list.
            Secrets::App::Commands.register klass
          end
        end

        attr_accessor :cli

        def initialize(cli)
          self.cli = cli
        end

        def opts
          cli.opts
        end

        def key
          @key ||= opts[:private_key]
        end

        def run
          raise Secrets::Errors::AbstractMethodCalled.new(:run)
        end

      end
    end
  end
end
