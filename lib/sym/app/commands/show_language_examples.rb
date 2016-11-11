require 'colored2'
require_relative 'command'
require_relative '../nlp'
module Sym
  module App
    module Commands
      class ShowLanguageExamples < Command
        required_options :language
        try_after :show_help



        def execute
          output = []

          output << Sym::App::NLP::Base.usage

          output << example(comment: 'generate a new private key and copy to the clipboard but do not print to terminal',
                            command: 'sym create new key to clipboard quietly'
          )

          output << example(comment: 'generate and save to a file a password-protected key, silently',
                            command: 'sym create a secure key and save it to "my.key"',
          )

          output << example(comment: 'encrypt a plain text string with a key, and save the output to a file',
                            command: 'sym encrypt string "secret string" using $(cat my.key) save to file.enc')

          output << example(comment: 'decrypt a previously encrypted string:',
                            command: 'sym decrypt string $ENC using $(cat my.key)')

          output << example(comment: 'encrypt "file.txt" with key from my.key and save it to file.enc',
                            command: 'sym encrypt file file.txt with key from my.key and save it to file.enc')

          output << example(comment: 'decrypt an encrypted file and print it to STDOUT:',
                            command: 'sym decrypt file file.enc with key from "my.key"')

          output << example(comment: 'edit an encrypted file in $EDITOR, ask for key, and create a backup upon save',
                            command: 'sym edit file file.enc ask for a key and make a backup',
          )

          if Sym::App.is_osx?
            output << example(comment: 'generate a new password-encrypted key, save it to your Keychain:',
                              command: 'sym create a new protected key store in keychain "my-keychain-key"')

            output << example(comment: 'print the key stored in the keychain item "my-keychain-key"',
                              command: 'sym print keychain "my-keychain-key"')

            output << example(comment: 'use the new key to encrypt a file:',
                              command: 'sym encrypt with keychain "my-keychain-key" file "password.txt" and write to "passwords.enc"')

          end

          output.flatten.compact.join("\n")
        end

        def example(comment: nil, command: nil, echo: nil, result: nil)
          @dict   ||= ::Sym::App::NLP::Constants::DICTIONARY.to_a.flatten!
          _command = command.split(' ').map do |w|
            _w = w.to_sym
            if w == 'sym'
              w.italic.yellow
            elsif ::Sym::App::NLP::Constants::STRIPPED.include?(_w)
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
