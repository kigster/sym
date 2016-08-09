require 'colored2'
require_relative 'command'
module Secrets
  module App
    module Commands
      class ShowExamples < Command
        required_options :examples

        def run
          output = []

          output << example(comment: 'generate a new private key into an environment variable:',
                            command: 'export KEY=$(secrets -g)',
                            echo:    'echo $KEY',
                            result:  '75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4='.green)

          output << example(comment: 'generate a new password-protected key, copy to the clipboard & save to a file',
                            command: 'secrets -gpc -o ~/.key',
                            echo:    'New Password     : ' + '••••••••••'.green,
                            result:  'Confirm Password : ' + '••••••••••'.green)

          output << example(comment: 'encrypt a plain text string with a key, and save the output to a file',
                            command: 'secrets -e -s ' + '"secret string"'.bold.yellow + ' -k $KEY -o file.enc',
                            echo:    'cat file.enc',
                            result:  'Y09MNDUyczU1S0UvelgrLzV0RTYxZz09CkBDMEw4Q0R0TmpnTm9md1QwNUNy%T013PT0K'.green)

          output << example(comment: 'decrypt a previously encrypted string:',
                            command: 'secrets -d -s $(cat file.enc) -k $KEY',
                            result:  'secret string'.green)

          output << example(comment: 'encrypt secrets.yml and save it to secrets.enc:',
                            command: 'secrets -e -f secrets.yml -o secrets.enc -k $KEY')

          output << example(comment: 'decrypt an encrypted file and print it to STDOUT:',
                            command: 'secrets -df secrets.enc -k $KEY')

          output << example(comment: 'edit an encrypted file in $EDITOR, ask for key, create a backup',
                            command: 'secrets -tibf ecrets.enc',
                            result:  '
Private Key: ••••••••••••••••••••••••••••••••••••••••••••
Saved encrypted content to secrets.enc.

Diff:
3c3
'.white.dark + '# (c) 2015 Konstantin Gredeskoul.  All rights reserved.'.red.bold  + '
---' + '
# (c) 2016 Konstantin Gredeskoul.  All rights reserved.'.green.bold)

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
