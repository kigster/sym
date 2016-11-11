require 'pp'
module Sym
  module App
    #     sym generate key to the clipboard and keychain
    #     sym encrypt file 'hello' using $key [to output.enc]
    #     sym edit 'passwords.enc' using $key
    #     sym decrypt /etc/secrets encrypted with $key save to ./secrets
    #     sym encrypt file $input with keychain $item
    module NLP
      module Usage

        def usage
          out = ''
          out << %Q`
#{header('Natural Language Processing')}

#{'When '.dark.normal}#{'sym'.bold.blue} #{'is invoked, and the first argument does not begin with a dash,
then the the NLP (natural language processing) Translator is invoked.
The Translator is based on a very simple algorithm:

 * ignore any of the words tagged STRIPPED. These are the ambiguous words,
   or words with duplicate meaning.

 * map the remaining arguments to regular double-dashed options using the DICTIONARY

 * words that are a direct match for a --option are automatically double-dashed

 * remaining words are left as is (these would be file names, key names, etc).

 * finally, the resulting "new" command line is parsed with regular options.

 * When arguments include "verbose", NLP system will print "before" and "after"
   of the arguments, so that any issues can be debugged and corrected.

'.dark.normal}

#{header('Currently ignored words:')}
    #{Constants::STRIPPED.join(', ').red.italic}

#{header('Regular Word Mapping')}
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
            '   ───────➤   '.dark,
            sprintf('--%-20.20s', right).blue,

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
