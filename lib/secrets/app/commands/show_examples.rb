require 'colored2'
module Secrets
  module App
    module Commands
      class ShowExamples < Command
        required_options :examples

        def run
          output = []
          output << '# EXAMPLES:                                                           '.bold.blue.underlined
          output << ''

          output << example(comment: 'generate a new secret:',
                            command: 'export KEY=$(secrets -g)',
                            echo:    'echo $KEY',
                            result:  '75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4=')

          output << example(comment: 'encrypt a plain text string with the key:',
                            command: 'export ENCRYPTED=$(secrets -e -s "secret string" -k $KEY)',
                            echo:    'echo $ENCRYPTED',
                            result:  'Y09MNDUyczU1S0UvelgrLzV0RTYxZz09CkBDMEw4Q0R0TmpnTm9md1QwNUNy%T013PT0K')

          output << example(comment: 'decrypt a previously encrypted string:',
                            command: 'secrets -d -s $ENCRYPTED -k $KEY',
                            result:  'secret string')

          output << example(comment: 'encrypt secrets.yml and save it to secrets.enc:',
                            command: 'secrets -e -f secrets.yml -o secrets.enc -k $KEY')

          output << example(comment: 'decrypt an encrypted file and print it to STDOUT:',
                            command: 'secrets -d -f secrets.enc -k $KEY')

          output.flatten.compact.join("\n")
        end

        def example(comment: nil, command: nil, echo: nil, result: nil)
          out = []
          out << "# #{comment}".black.on.white.italic if comment
          out << "#{command}".bold if command
          out << "#{echo}".bold if echo
          out << "# #{result}".bold.cyan if result
          out << ' '
        end
      end
    end
  end
end
