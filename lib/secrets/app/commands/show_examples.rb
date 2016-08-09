require 'colored2'
module Secrets
  module App
    module Commands
      class ShowExamples < Command
        required_options :examples

        def run
          output = []

          output << example(comment: 'generate a new secret:',
                            command: 'export KEY=$(secrets -g)',
                            echo:    'echo $KEY',
                            result:  '75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4='.green)

          output << example(comment: 'encrypt a plain text string with the key:',
                            command: 'export ENCRYPTED=$(secrets -e -s ' + '"secret string"'.bold.yellow + ' -k $KEY)',
                            echo:    'echo $ENCRYPTED',
                            result:  'Y09MNDUyczU1S0UvelgrLzV0RTYxZz09CkBDMEw4Q0R0TmpnTm9md1QwNUNy%T013PT0K'.green)

          output << example(comment: 'decrypt a previously encrypted string:',
                            command: 'secrets -d -s $ENCRYPTED -k $KEY',
                            result:  'secret string'.green)

          output << example(comment: 'encrypt secrets.yml and save it to secrets.enc:',
                            command: 'secrets --encrypt --file secrets.yml --output secrets.enc -k $KEY')

          output << example(comment: 'decrypt an encrypted file and print it to STDOUT:',
                            command: 'secrets --decrypt -f secrets.enc -k $KEY')

          output << example(comment: 'edit an encrypted file in $EDITOR, ask for key, create a backup',
                            command: 'secrets -t -f secrets.enc -i -b -v ',
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
          out << "#{echo}".bold if echo
          out << "#{result}" if result
          out << '—'*80
        end
      end
    end
  end
end
