require 'pp'
module Shhh
  module App
    #     shhh generate key to the clipboard and keychain
    #     shhh encrypt file 'hello' using $key [to output.enc]
    #     shhh edit 'passwords.enc' using $key
    #     shhh decrypt /etc/secrets encrypted with $key save to ./secrets
    #     shhh encrypt file $input with keychain $item
    module NLP
      module Usage

        def usage
          out = ''
          out << %Q`
#{header('Natural Language Processing')}

#{'When shhh is called, but none of the arguments contain a dash, then the
the NLP (natural language processing) Translator is invoked. The Translator is
based on a very simple algorithm:

 * ignore all of the ambiguous words, or words with duplicate meaning
 * unambiguously map arguments to the regular options (the double-dash version)
 * words that already match double-dash options are double-dashed
 * the mapping of words into --options is performed
 * the result is parsed

When verbose is provided as an argument, you will additionally see the command line
arguments that NLP system had produced following the mapping of the actual arguments.
This may be helpful in diagnosis of why a particular sentence is not recognized.'.dark.normal}

#{header('Currently ignored words:')}
    #{Constants::STRIPPED.join(', ').red.italic}

#{header('Currently Dictionary')}
#{Constants::DICTIONARY.pretty_inspect.split(/\n/).map do |line|
            line.gsub(
              /[\:\}\,\[\]]/, ''
            ).gsub(
              /[ {](\w+)=>([^\n]*)/, '\2|\1'
            )
          end.map { |line| convert_dictionary(*line.split('|')) }.join}

#{header('Examples')}
`
          out
        end

        def convert_dictionary(left = '', right = '')
          [
            sprintf('%35.35s', left.gsub(/ /, ' ')).italic.yellow,
            ' >————————➤ '.dark,
            sprintf('%-20.20s', right).blue,

            "\n"
          ].join
        end

        private
        def header(title)
          title.upcase.bold.underlined
        end

      end
    end
  end
end
