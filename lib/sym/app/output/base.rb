require 'sym/app/short_name'
module Sym
  module App
    module Output
      class Base

        attr_accessor :cli

        def initialize(cli)
          self.cli = cli
        end

        def opts
          cli.opts
        end

        @outputs = []
        class << self
          attr_accessor :outputs

          def append(output_klass)
            outputs << output_klass if outputs.is_a?(Array)
            raise "Cannot append #{output_class} after #outputs has been converted to a Hash" \
              unless outputs.is_a?(Array)
          end

          def map_outputs!
            klasses      = self.outputs
            self.outputs = Hash.new
            klasses.each { |k| self.outputs[k.required_option] = k }
            outputs
          end

          def options_to_outputs
            map_outputs! if outputs.is_a?(Array)
            outputs
          end
        end

        def self.inherited(klass)
          klass.instance_eval do
            class << self
              attr_writer :required_option
            end

            klass.required_option = nil

            class << self
              def required_option(_option = nil)
                self.required_option = _option if _option
                @required_option
              end
            end
          end
          klass.extend(Sym::App::ShortName)
          Sym::App::Output::Base.append klass
        end
      end
    end
  end
end
