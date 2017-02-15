module Sym
  module App
    module CLISlop
      def parse(arguments)
        Slop.parse(arguments) do |o|

          o.banner = "Sym (#{Sym::VERSION}) – encrypt/decrypt data with a private key\n".bold.white
          o.separator 'Usage:'.yellow
          o.separator '   # Generate a new key...'.dark
          o.separator '   sym -g '.green.bold + '[ -p ] [ -x keychain | -o keyfile | -q | ]  '.green
          o.separator ''
          o.separator '   # To specify a key for an operation use one of...'.dark
          o.separator '   ' + key_spec + ' = -k key | -K file | -x keychain | -i '.green.bold
          o.separator ''
          o.separator '   # Encrypt/Decrypt to STDOUT or an output file '.dark
          o.separator '   sym -e '.green.bold + key_spec + ' [-f <file> | -s <string>] [-o <file>] '.green
          o.separator '   sym -d '.green.bold + key_spec + ' [-f <file> | -s <string>] [-o <file>] '.green
          o.separator ' '
          o.separator '   # Edit an encrypted file in $EDITOR '.dark
          o.separator '   sym -t '.green.bold + key_spec + '  -f <file> [ -b ]'.green.bold

          o.separator ' '
          o.separator '   # Specify any common flags in the BASH variable:'.dark
          o.separator '   export SYM_ARGS="'.green + '-x staging -C'.bold.green + '"'.green
          o.separator ' '
          o.separator '   # And now encrypt without having to specify key location:'.dark
          o.separator '   sym -e '.green.bold '-f <file>'.green.bold
          o.separator '   # May need to disable SYM_ARGS with -M, eg for help:'.dark
          o.separator '   sym -h -M '.green.bold

          o.separator ' '
          o.separator 'Modes:'.yellow
          o.bool      '-e', '--encrypt',            '           encrypt mode'
          o.bool      '-d', '--decrypt',            '           decrypt mode'
          o.bool      '-t', '--edit',               '           edit encrypted file in an $EDITOR'

          o.separator ' '
          o.separator 'Create a new private key:'.yellow
          o.bool      '-g', '--generate',           '           generate a new private key'
          o.bool      '-p', '--password',           '           encrypt the key with a password'

          o.separator ' '
          o.separator 'Read existing private key from:'.yellow
          o.string    '-k', '--private-key',        '[key]     '.blue + ' private key (or key file)'
          o.string    '-K', '--keyfile',            '[key-file]'.blue + ' private key from a file'
          if Sym::App.is_osx?
            o.string '-x', '--keychain',            '[key-name] '.blue + 'add to (or read from) the OS-X Keychain'
          end
          o.bool      '-i', '--interactive',        '           Paste or type the key interactively'

          o.separator ' '
          o.separator 'Password Cache:'.yellow
          o.bool      '-C', '--cache-password',     '           enable the cache (off by default)'
          o.integer   '-T', '--cache-for',          '[seconds]'.blue + '  to cache the password for'
          o.string    '-P', '--cache-provider',     '[provider]'.blue + ' type of cache, one of: ' + "\n\t\t\t\t    " +
            "[ #{Sym::App::Password::Providers.registry.keys.map(&:to_s).join(', ').blue.bold} ]"

          o.separator ' '
          o.separator 'Data to Encrypt/Decrypt:'.yellow
          o.string    '-s', '--string',             '[string]'.blue + '   specify a string to encrypt/decrypt'
          o.string    '-f', '--file',               '[file]  '.blue + '   filename to read from'
          o.string    '-o', '--output',             '[file]  '.blue + '   filename to write to'

          o.separator ' '
          o.separator 'Flags:'.yellow
          o.bool      '-b', '--backup',             '           create a backup file in the edit mode'
          o.bool      '-v', '--verbose',            '           show additional information'
          o.bool      '-A', '--trace',              '           print a backtrace of any errors'
          o.bool      '-D', '--debug',              '           print debugging information'
          o.bool      '-q', '--quiet',              '           do not print to STDOUT'
          o.bool      '-V', '--version',            '           print library version'
          o.bool      '-N', '--no-color',           '           disable color output'
          o.bool      '-M', '--no-environment',     '           disable reading flags from SYM_ARGS'

          o.separator ' '
          o.separator 'Utility:'.yellow
          o.string    '-a', '--bash-completion',    '[file]'.blue + '     append shell completion to a file'

          o.separator ' '
          o.separator 'Help & Examples:'.yellow
          o.bool      '-E', '--examples',           '           show several examples'
          o.bool      '-h', '--help',               '           show help'
        end
      end
    end
  end
end
