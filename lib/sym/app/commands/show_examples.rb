require 'colored2'
require_relative 'command'
module Sym
  module App
    module Commands
      class ShowExamples < Command
        required_options :examples
        try_after :show_help

        def execute
          output = []

          output << example(comment: 'generate a new private key into an environment variable:',
                            command: 'export KEY=$(sym -g)',
                            echo:    'echo $KEY',
                            result:  '75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4='.green)

          output << example(comment: 'generate a new password-protected key, copy to the clipboard & save to a file',
                            command: 'sym -gpc -o ~/.key',
                            echo:    'New Password     : ' + '••••••••••'.green,
                            result:  'Confirm Password : ' + '••••••••••'.green)

          output << example(comment: 'encrypt a plain text string with a key, and save the output to a file',
                            command: 'sym -e -s ' + '"secret string"'.bold.yellow + ' -k $KEY -o file.enc',
                            echo:    'cat file.enc',
                            result:  'Y09MNDUyczU1S0UvelgrLzV0RTYxZz09CkBDMEw4Q0R0TmpnTm9md1QwNUNy%T013PT0K'.green)

          output << example(comment: 'decrypt a previously encrypted string:',
                            command: 'sym -d -s $(cat file.enc) -k $KEY',
                            result:  'secret string'.green)

          output << example(comment: 'encrypt sym.yml and save it to sym.enc:',
                            command: 'sym -e -f sym.yml -o sym.enc -k $KEY')

          output << example(comment: 'decrypt an encrypted file and print it to STDOUT:',
                            command: 'sym -df sym.enc -k $KEY')

          output << example(comment: 'edit an encrypted file in $EDITOR, ask for key, create a backup',
                            command: 'sym -tibf ecrets.enc',
                            result:  '
Private Key: ••••••••••••••••••••••••••••••••••••••••••••
Saved encrypted content to sym.enc.

Diff:
3c3
'.white.dark + '# (c) 2015 Konstantin Gredeskoul.  All rights reserved.'.red.bold  + '
---' + '
# (c) 2016 Konstantin Gredeskoul.  All rights reserved.'.green.bold)


          if Sym::App.is_osx?
          output << example(comment: 'generate a new password-encrypted key, save it to your Keychain:',
                            command: 'sym -gpx mykey -o ~/.key')

          output << example(comment: 'use the new key to encrypt a file:',
                            command: 'sym -x mykey -e -f password.txt -o passwords.enc')

          output << example(comment: 'use the new key to inline-edit the encrypted file:',
                            command: 'sym -x mykey -t -f sym.yml')
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
