# Sym CLI Help Screen

```text
Sym (2.5.1) – encrypt/decrypt data with a private key

Usage:
   Generate a new key, optionally password protected, and save it
   in one of: keychain, file, or STDOUT (-q turns off STDOUT) 
 
       sym -g [ -p/--password ] [-c] [-x keychain | -o file | ] [-q]

   To specify encryption key, provide the key as 
      1) a string, 2) a file path, 3) an OS-X Keychain, 4) env variable name 
      5) use -i to paste/type the key interactively
      6) default key file (if present) at /Users/kig/.sym.key
 
       KEY-SPEC = -k/--key [ key | file | keychain | env variable name ]
                  -i/--interactive

   Encrypt/Decrypt from STDIN/file/args, to STDOUT/file:
 
       sym -e/--encrypt KEY-SPEC [-f [file | - ] | -s string ] [-o file] 
       sym -d/--decrypt KEY-SPEC [-f [file | - ] | -s string ] [-o file] 

   Auto-detect mode based on a special file extension ".enc"
 
       sym -n/--negate  KEY-SPEC file[.enc] 
 
   Edit an encrypted file in $EDITOR 
 
       sym -t/--edit    KEY-SPEC -f file [ -b/--backup ]
 
   Save commonly used flags in a BASH variable. Below we save the KeyChain 
   "staging" as the default key name, and enable password caching.
 
       export SYM_ARGS="-ck staging"
 
   Then activate $SYM_ARGS by using -A/--sym-args flag:
 
       sym -Aef file
 
Modes:
  -e, --encrypt                     encrypt mode
  -d, --decrypt                     decrypt mode
  -t, --edit                        edit encrypted file in an $EDITOR
  -n, --negate           [file]     encrypts any regular file into file.enc
                                    conversely decrypts file.enc into file.
 
Create a new private key:
  -g, --generate                    generate a new private key
  -p, --password                    encrypt the key with a password
  -x, --keychain         [key-name] write the key to OS-X Keychain
 
Read existing private key from:
  -k, --key              [key-spec] private key, key file, or keychain
  -i, --interactive                 Paste or type the key interactively
 
Password Cache:
  -c, --cache-passwords             enable password cache
  -u, --cache-timeout    [seconds]  expire passwords after
  -r, --cache-provider   [provider] cache provider, one of memcached, drb
 
Data to Encrypt/Decrypt:
  -s, --string           [string]   specify a string to encrypt/decrypt
  -f, --file             [file]     filename to read from
  -o, --output           [file]     filename to write to
 
Flags:
  -b, --backup                      create a backup file in the edit mode
  -v, --verbose                     show additional information
  -q, --quiet                       do not print to STDOUT
  -T, --trace                       print a backtrace of any errors
  -D, --debug                       print debugging information
  -V, --version                     print library version
  -N, --no-color                    disable color output
  -A, --sym-args                    read more CLI arguments from $SYM_ARGS
 
Utility:
  -B, --bash-support     [file]     append bash completion & utils to a file
                                    such as ~/.bash_profile or ~/.bashrc
 
Help & Examples:
  -E, --examples                    show several examples
  -h, --help                        show help
```

## Examples

```bash
# generate a new private key into an environment variable:
export mykey=$(sym -g)
echo $mykey
75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4=
————————————————————————————————————————————————————————————————————————————————
# generate a new key with a cached password & save to the default key file
sym -gcpqo /Users/kig/.sym.key
New Password     : ••••••••••
Confirm Password : ••••••••••
————————————————————————————————————————————————————————————————————————————————
# encrypt a plain text string with default key file, and immediately decrypt it
sym -es "secret string" | sym -d
secret string
————————————————————————————————————————————————————————————————————————————————
# encrypt secrets file using key in the environment, and --negate option:
export PRIVATE_KEY="75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4="
sym -ck PRIVATE_KEY -n secrets.yml

————————————————————————————————————————————————————————————————————————————————
# encrypt a secrets file using the key in the keychain:
sym -gqx keychain.key
sym -ck keychain.key -n secrets.yml
secret string
————————————————————————————————————————————————————————————————————————————————
# encrypt/decrypt sym.yml using the default key file
sym -gcq > /Users/kig/.sym.key
sym -n secrets.yml
sym -df secrets.yml.enc
————————————————————————————————————————————————————————————————————————————————
# decrypt an encrypted file and print it to STDOUT:
sym -ck production.key -df secrets.yml.enc
————————————————————————————————————————————————————————————————————————————————
# edit an encrypted file in $EDITOR, use default key file, create file backup
sym -tbf secrets.enc

Private Key: ••••••••••••••••••••••••••••••••••••••••••••
Saved encrypted content to sym.enc.

Diff:
3c3
# (c) 2015 Konstantin Gredeskoul.  All rights reserved.
---
# (c) 2016 Konstantin Gredeskoul.  All rights reserved.
————————————————————————————————————————————————————————————————————————————————
# generate a new password-encrypted key, save it to your Keychain:
sym -gpcx staging.key
————————————————————————————————————————————————————————————————————————————————
# use the new key to encrypt a file:
sym -e -c -k staging.key -n etc/passwords.enc
————————————————————————————————————————————————————————————————————————————————
# use the new key to inline-edit the encrypted file:
sym -k mykey -tf sym.yml.enc
————————————————————————————————————————————————————————————————————————————————
```
