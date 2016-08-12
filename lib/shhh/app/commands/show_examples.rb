require 'colored2'
require_relative 'command'
module Shhh
  module App
    module Commands
      class ShowExamples < Command
        required_options :examples
        try_after :show_help

        def run
          output = []

          output << example(comment: 'generate a new private key into an environment variable:',
                            command: 'export KEY=$(shhh -g)',
                            echo:    'echo $KEY',
                            result:  '75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4='.green)

          output << example(comment: 'generate a new password-protected key, copy to the clipboard & save to a file',
                            command: 'shhh -gpc -o ~/.key',
                            echo:    'New Password     : ' + '••••••••••'.green,
                            result:  'Confirm Password : ' + '••••••••••'.green)

          output << example(comment: 'encrypt a plain text string with a key, and save the output to a file',
                            command: 'shhh -e -s ' + '"secret string"'.bold.yellow + ' -k $KEY -o file.enc',
                            echo:    'cat file.enc',
                            result:  'Y09MNDUyczU1S0UvelgrLzV0RTYxZz09CkBDMEw4Q0R0TmpnTm9md1QwNUNy%T013PT0K'.green)

          output << example(comment: 'decrypt a previously encrypted string:',
                            command: 'shhh -d -s $(cat file.enc) -k $KEY',
                            result:  'secret string'.green)

          output << example(comment: 'encrypt shhh.yml and save it to shhh.enc:',
                            command: 'shhh -e -f shhh.yml -o shhh.enc -k $KEY')

          output << example(comment: 'decrypt an encrypted file and print it to STDOUT:',
                            command: 'shhh -df shhh.enc -k $KEY')

          output << example(comment: 'edit an encrypted file in $EDITOR, ask for key, create a backup',
                            command: 'shhh -tibf ecrets.enc',
                            result:  '
Private Key: ••••••••••••••••••••••••••••••••••••••••••••
Saved encrypted content to shhh.enc.

Diff:
3c3
'.white.dark + '# (c) 2015 Konstantin Gredeskoul.  All rights reserved.'.red.bold  + '
---' + '
# (c) 2016 Konstantin Gredeskoul.  All rights reserved.'.green.bold)


          if Shhh::App.is_osx?
          output << example(comment: 'generate a new password-encrypted key, save it to your Keychain:',
                            command: 'shhh -gpx mykey -o ~/.key')

          output << example(comment: 'use the new key to encrypt a file:',
                            command: 'shhh -x mykey -e -f password.txt -o passwords.enc')

          output << example(comment: 'use the new key to inline-edit the encrypted file:',
                            command: 'shhh -x mykey -t -f shhh.yml')
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
