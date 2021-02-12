require 'colored2'
require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class ShowExamples < BaseCommand
        required_options :examples
        try_after :show_version

        def execute
          output = []

          output << example(comment: 'generate a new private key into an environment variable:',
                            command: 'export mykey=$(sym -g)',
                            echo:    'echo $mykey',
                            result:  '75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4='.green)

          output << example(comment: 'generate a new key with a cached password & save to the default key file',
                            command: "sym -gcpqo #{Sym.default_key_file}",
                            echo:    "New Password     : #{'••••••••••'.green}",
                            result:  "Confirm Password : #{'••••••••••'.green}")

          output << example(comment: 'encrypt a plain text string with default key file, and immediately decrypt it',
                            command: "sym -es #{'"secret string"'.bold.yellow} | sym -d",
                            result:  'secret string'.green)

          output << example(comment: 'encrypt secrets file using key in the environment, and --negate option:',
                            command: 'export PRIVATE_KEY="75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4="',
                            echo:    'sym -ck PRIVATE_KEY -n secrets.yml',
                            result:  ''.green)

          output << example(comment: 'encrypt a secrets file using the key in the keychain:',
                            command: 'sym -gqx keychain.key',
                            echo:    'sym -ck keychain.key -n secrets.yml',
                            result:  'secret string'.green)

          output << example(comment: 'encrypt/decrypt sym.yml using the default key file',
                            command: "sym -gcq > #{Sym.default_key_file}",
                            echo:    'sym -n secrets.yml',
                            result:  'sym -df secrets.yml.enc',
          )

          output << example(comment: 'decrypt an encrypted file and print it to STDOUT:',
                            command: 'sym -ck production.key -df secrets.yml.enc')

          output << example(comment: 'edit an encrypted file in $EDITOR, use default key file, create a backup',
                            command: 'sym -bt secrets.enc',
                            result:  '
Private Key: ••••••••••••••••••••••••••••••••••••••••••••
Saved encrypted content to sym.enc.

Diff:
3c3
'.white.dark + '# (c) 2015 Konstantin Gredeskoul.  All rights reserved.'.red.bold  + '
---' + '
# (c) 2016 Konstantin Gredeskoul.  All rights reserved.'.green.bold)


          if Sym::App.osx?
          output << example(comment: 'generate a new password-encrypted key, save it to your Keychain:',
                            command: 'sym -gpcx staging.key')

          output << example(comment: 'use the new key to encrypt a file:',
                            command: 'sym -e -c -k staging.key -n etc/passwords.enc')

          output << example(comment: 'use the new key to inline-edit the encrypted file:',
                            command: 'sym -k mykey -t sym.yml.enc')
          end

          output.flatten.compact.join("\n")
        end

        def example(comment: nil, command: nil, echo: nil, result: nil)
          out = []
          out << "# #{comment}".white.dark.italic if comment
          out << command if command
          out << echo if echo
          out << result if result
          out << '—'*80
        end
      end
    end
  end
end
