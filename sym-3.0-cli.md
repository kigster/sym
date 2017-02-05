# Sym 

__Sym__ is a versatile encryption gem, based on the symmetric encryption cipher provided by the OpenSSL. It provides easy to remember commands to manage encryption key: you can generate a key, import an existing key, password protect an open key, store the key in OS-X KeyChain, and use it for encryption/decryption later. The key is used to encrypt, decrypt and edit any sensitive information, such application secrets.

## Usage

    sym [ global options ] [ sub command ] [ command options ] 
    
### Global Options
    
```bash
-t, --password-timeout   [timeout]  when passwords expire (in seconds)
-p, --no-password-cache             disables caching of key passwords   
-v, --verbose                       show additional information
-T, --trace                         print a backtrace of any errors
-q, --quiet                         silence all output
-V, --version                       print library version
-N, --no-color                      disable color output
```

### Help & Examples:

```bash
-h, --help                          show help
-l, --long                          show help and detailed examples
```

### Commands

###### Genereate a new key
```bash
sym key [ [ --out      | -o ] uri ] # or STDOUT by default
# eg.
> sym key -o stdout
> sym key -o file://~/.key
```

###### Copy or Re-Import a Key

Typically applied to an existing key, optionally password-protecting it:

```bash
sym key   [ --in       | -k ] uri 
        [ [ --out      | -o ] uri ] # or STDOUT by default
          [ --password | -p ] 
# eg.
> sym key -k file://~/.key -o keychain://mykey -p 

> sym key -k stdin -o keychain://mykey -p           
Please enter the encryption key: 75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4=
Please enter new password:
Please confirm the new password: 
```

###### Delete an existing key (assuming URI supports deletion):

```bash
sym key   [ --delete   | -d ] uri

# eg.
> sym key -d keychain://mykey
> sym key -d redis://127.0.0.1:6379/1/symkey
```

###### Encrypt or Decrypt a Resource

```bash
sym decrypt   [ --key      | -k ] uri 
              [ --data     | -d ] uri
            [ [ --out      | -o ] uri ]

sym encrypt   [ --key      | -k ] uri 
              [ --data     | -d ] uri
            [ [ --out      | -o ] uri ]
```

###### Open Encrypted Resource in an Editor

```bash
sym edit      [ --key      | -k ] uri 
              [ --data     | -d ] uri
            [ [ --backup   | -b ] data-backup-uri
```
###### Re-encrypt data, and rotate the key

For key and data URIs that support update operation (eg, `file://`, `keychain://`)
this operation decrypts the resource with the current key, generates
a new key, re-encrypts the data, and updates both the resource and the 
key URIs.

```bash
sym cycle     [ --key      | -k ] uri 
              [ --data     | -d ] uri
            [ [ --out      | -o ] uri ]
# eg:
sym cycle -k file://~/.key -d file://./secrets.yml
```

###### Installation, Help, and Other Commands

```bash            
sym install bash-completion

sym --help | -h

sym command --help | -h
   
sym examples
```

##### Arguments via Environment

Common arguments can be passed in an environment variable called `SYM_ARGS`:

    export SYM_ARGS='-k file://~/.sym.key'
    
The name of the variable can be read from the `-B <name>` argument, eg:

    SYM_ARGUMENTS='-k 75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4'
    sym -B SYM_ARGUMENS -d file://file.enc

##### Subcommands

When loading the commands, we use the hierarchical loading:

    require 'sym/app/cmd'
    require 'sym/app/cmd/bash'
    require 'sym/app/cmd/bash/completion'


### Reading and Writing Data and Keys

The new CLI for Sym uses a consistent naming for reading in the data and the key, and for writing out the key and/or data. The scheme is based on URI.

Each URI type is supported by a corresponding plugin, and new ones can be easily defined.  

Some examples:
   
```bash   
 string://234234234          # read from the literal data
 file://home/kig/.mykey      # read/write from/to file
 env://MY_VARIABLE           # read from environment variable
 stdio://                    # read/write using stdin/out

 https://mysite.com/remote/secrets.json.enc
 file:///usr/local/etc/secrets.json
```

Below is the list of supported types planned for 3.0:

#### Supported Types

```bash
 URI:                                   Read? Write? Delete?
 
 string://value                          yes      
 env://variable                          yes    
 stdio://                                yes
 shell://command                         yes   yes   yes
 file://filename                         yes   yes   yes
 keychain://name                         yes   yes   yes
 redis://127.0.0.1:6397/1/mykey          yes   yes   yes
 memcached://127.0.0.1:11211/mykey       yes   yes   yes
 scp://user@host/path/file               yes   yes   yes
 http[s]://user@host/path/file           yes   yes   yes
```
