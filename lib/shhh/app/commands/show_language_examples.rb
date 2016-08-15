require 'colored2'
require_relative 'command'
require_relative '../nlp'
module Shhh
  module App
    module Commands
      class ShowLanguageExamples < Command
        required_options :language
        try_after :show_help

        def run
          output = []

          output << Shhh::App::NLP::Base.usage

          output << example(comment: 'generate a new private key and copy to the clipboard',
                            command: 'shhh make new key and copy it to the clipboard'
          )

          output << example(comment: 'generate and save to a file a password-protected key, silently',
                            command: 'shhh create a secure key and save it to "my.key"',
          )

          output << example(comment: 'encrypt a plain text string with a key, and save the output to a file',
                            command: 'shhh encrypt string "secret string" using $KEY save to file.enc')

          output << example(comment: 'decrypt a previously encrypted string:',
                            command: 'shhh decrypt string $ENC using a $KEY')

          output << example(comment: 'encrypt shhh.yml with key from $KEYFILE and save it to shhh.enc',
                            command: 'shhh encrypt shhh.yml with key from $KEYFILE and save it to shhh.enc')

          output << example(comment: 'decrypt an encrypted file and print it to STDOUT:',
                            command: 'shhh decrypt file data.enc using $KEY')

          output << example(comment: 'edit an encrypted file in $EDITOR, ask for key, create a backup',
                            command: 'shhh edit file ecrets.enc ask for a key and make a backup',
          )


          if Shhh::App.is_osx?
            output << example(comment: 'generate a new password-encrypted key, save it to your Keychain:',
                              command: 'shhh generate key with a password to keychain "kyname"')

            output << example(comment: 'use the new key to encrypt a file:',
                              command: 'shhh encrypt with keychain item "keyname" file password.txt save to passwords.enc')

          end

          output.flatten.compact.join("\n")
        end

        def example(comment: nil, command: nil, echo: nil, result: nil)
          @dict   ||= ::Shhh::App::NLP::Constants::DICTIONARY.to_a.flatten!
          _command = command.split(' ').map do |w|
            _w = w.to_sym
            if w == 'shhh'
              w.italic.yellow
            elsif ::Shhh::App::NLP::Constants::STRIPPED.include?(_w)
              w.italic.red
            elsif @dict.include?(_w)
              w.blue
            else
              w
            end
          end.join(' ') if command
          out     = []
          out << "# #{comment}".white.dark.italic if comment
          out << "#{_command}" if command
          out << "#{echo}" if echo
          out << "#{result}" if result
          out << (' '*80).dark
        end
      end
    end
  end
end
