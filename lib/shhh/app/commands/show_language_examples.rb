require 'colored2'
require_relative 'command'
module Shhh
  module App
    module Commands
      class ShowLanguageExamples < Command
        required_options :language
        try_after :show_help

        def run
          output = []

          output << example(comment: 'generate a new private key and copy to the clipboard',
                            command: 'shhh generate key and copy to clipboard'
          )

          output << example(comment: 'generate and save to a file a password-protected key, silently',
                            command: 'shhh generate key with password and save to file',
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
          out = []
          out << "# #{comment}".white.dark.italic if comment
          out << "#{command}" if command
          out << "#{echo}" if echo
          out << "#{result}" if result
          out << '—'*80
        end
      end
    end
  end
end
