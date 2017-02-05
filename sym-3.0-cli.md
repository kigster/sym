## Sym 

> Sym is a versatile encryption gem, based on the symmetric encryption cipher provided by the OpenSSL. It provides easy to remember commands to manage encryption key: you can generate a key, import an existing key, password protect an open key, store the key in OS-X KeyChain, and use it for encryption/decryption later. The key is used to encrypt, decrypt and edit any sensitive information, such application secrets.

### Complete Usage

    sym [ global options ] [ sub command ] [ command options ] 
    
##### Global Options
    
```bash
-M, ——password-timeout   [timeout]  when passwords expire (in seconds)
-P, ——no-password-cache             disables caching of key passwords   
-v, ——verbose                       show additional information
-T, ——trace                         print a backtrace of any errors
-q, ——quiet                         silence all output
-V, ——version                       print library version
-N, ——no-color                      disable color output
```

##### Help & Examples:

```bash
-h, ——help                          show help
-l, ——long                          show help and detailed examples
```

##### Commands

    # Genereate new key
    sym key ——save [ key-source ]
   
    # Copy existing key, optionally password-protected:
    sym key ——save [ key-source ] ——key [ key-source ] [ -p ] 
   
    # Delete existing key:
    sym key ——rm [ key-source ]

    sym decrypt ——key  | -k   key-source 
                ——data | -d   data-source
                ——to   | -t   data-source | ——in-place
 
    sym encrypt ——key  | -k   key-source 
                ——data | -d   data-source
                ——to   | -t   data-source | ——in-place
   
    sym edit    ——data | -d   data-source
                ——key  | -k   key-source
                ——bak  | -b   data-backup-source
                
    sym recrypt ——data | -d   data-source
                ——key  | -k   key-source 
                ——save | -s   key-source
                 
    sym install bash-completion

    sym --help | -h
    
    sym command --help | -h
    
    sym examples


##### Arguments via Environment

    export SYM_ARGS_KEY='@file "~/.sym.key"'
    export SYM_ARGS_DATA='@file "~/.sym.key"'

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
   ——key-in  string://234234234           # read from the literal data
   ——key-out file://home/kig/.mykey      # read/write from/to file
   ——key-in  env://MY_VARIABLE            # read from environment variable
   ——key-out stdio://                    # read/write using stdin/out
   
   --data-in  https://mysite.com/remote/secrets.json.enc
   --data-out file:///usr/local/etc/secrets.json
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
