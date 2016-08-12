require 'active_support/inflector'
module Shhh
  module App
    module Commands
      class Command

        def self.inherited(klass)
          klass.instance_eval do
            class << self
              attr_accessor :required, :incompatible

              def try_after(*dependencies)
                Shhh::App::Commands.order(self, dependencies)
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

              def short_name
                name.split(/::/)[-1].underscore.to_sym
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
            Shhh::App::Commands.register klass
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
          @key ||= cli.key
        end

        def run
          raise Shhh::Errors::AbstractMethodCalled.new(:run)
        end

      end
    end
  end
end
