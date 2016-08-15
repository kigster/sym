require_relative 'constants'
module Shhh
  module App
    module NLP
      class Translator

        attr_accessor :argv, :result, :cli, :opts

        def initialize(argv)
          self.argv   = argv
          self.cli    = CLI.new(%w(-E))
          self.opts   = cli.opts.to_hash
          self.result = []
        end

        def dict
          ::Shhh::App::NLP::Constants::DICTIONARY
        end

        def stripped
          ::Shhh::App::NLP::Constants::STRIPPED
        end

        def translate
          argv.each do |value|
            arg = nil
            arg ||= dict.keys.find do |key|
              dict[key].include?(value.to_sym) || key == value.to_sym
            end
            arg ||= value.to_sym

            if opts.to_hash.key?(arg)
              result << '--' + "#{arg.to_s.gsub(/_/, '-')}"
            else
              result << arg.to_s unless stripped.include?(arg)
            end
          end
          result
        end

        def run
          Shhh::App::CLI.new(translate).run
        end
      end
    end
  end
end
