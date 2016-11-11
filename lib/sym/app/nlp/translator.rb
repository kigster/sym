require_relative 'constants'
module Sym
  module App
    module NLP
      class Translator

        attr_accessor :argv, :translated_argv, :opts

        def initialize(argv)
          self.argv            = argv
          self.opts            = CLI.new(%w(-E)).opts.to_hash
          self.translated_argv = []
        end

        def dict
          ::Sym::App::NLP::Constants::DICTIONARY
        end

        def stripped
          ::Sym::App::NLP::Constants::STRIPPED
        end

        def translate
          self.translated_argv = argv.map do |value|
            nlp_argument = value.to_sym
            arg = nil
            arg ||= dict.keys.find do |key|
              dict[key].include?(nlp_argument) || key == nlp_argument
            end
            arg ||= nlp_argument

            if stripped.include?(arg)
              # nada
            elsif opts.to_hash.key?(arg)
              '--' + "#{arg.to_s.gsub(/_/, '-')}"
            else
              arg.to_s
            end
          end.compact

          counts = {}
          translated_argv.each{ |arg| counts.key?(arg) ? counts[arg] += 1 : counts[arg] = 1 }
          translated_argv.delete_if{ |arg| counts[arg] > 1 }
          self
        end

        def and
          translate if translated_argv.empty?
          if self.translated_argv.include?('--verbose')
            STDERR.puts 'Original arguments: '.dark + "#{argv.join(' ').green}"
            STDERR.puts '   Translated argv: '.dark + "#{translated_argv.join(' ').blue}"
          end
          ::Sym::App::CLI.new(self.translated_argv)
        end

        alias_method :application, :and

      end
    end
  end
end
