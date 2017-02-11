# Sym — Light Weight Symmetric Encryption for Humans

[![Gem Version](https://badge.fury.io/rb/sym.svg)](https://badge.fury.io/rb/sym)
[![Downloads](http://ruby-gem-downloads-badge.herokuapp.com/sym?type=total)](https://rubygems.org/gems/sym)
[![Documentation](http://inch-ci.org/github/kigster/sym.png)](http://inch-ci.org/github/kigster/sym)

[![Build Status](https://travis-ci.org/kigster/sym.svg?branch=master)](https://travis-ci.org/kigster/sym)
[![Code Climate](https://codeclimate.com/github/kigster/sym/badges/gpa.svg)](https://codeclimate.com/github/kigster/sym)
[![Test Coverage](https://codeclimate.com/github/kigster/sym/badges/coverage.svg)](https://codeclimate.com/github/kigster/sym/coverage)
[![Issue Count](https://codeclimate.com/github/kigster/sym/badges/issue_count.svg)](https://codeclimate.com/github/kigster/sym)

## Description

> __sym__ is a command line utility and a Ruby API that makes it _trivial to encrypt and decrypt sensitive data_. Unlike many other existing encryption tools, __sym__ focuses on usability and streamlined interface (CLI), with the goal of making encryption easy and transparent. The result? There is no excuse for keeping your application secrets unencrypted :) 

<hr />
## Table of Contents

<ul class="small site-footer-links">
<li>
<a href="#description">Description</a>
<ul>
<li>
<a href="#motivation">Motivation</a>
</li>
<li>
<a href="#whats-included">What&#39;s Included</a>
</li>
<li>
<a href="#how-it-works">How It Works</a>
</li>
</ul>
</li>
<li>
<a href="#installation">Installation</a>
</li>
<li>
<a href="#using-sym-with-the-command-line">Using <code>sym</code> with the Command Line</a>
<ul>
<li>
<a href="#private-keys">Private Keys</a>
<ul>
<li>
<a href="#generating-private-keys">Generating Private Keys</a>
</li>
<li>
<a href="#using-keychain-access-on-mac-os-x">Using KeyChain Access on Mac OS-X</a>
</li>
<li>
<a href="#keychain-key-management">KeyChain Key Management</a>
</li>
<li>
<a href="#moving-a-key-to-the-keychain">Moving a Key to the Keychain</a>
</li>
<li>
<a href="#adding-password-to-existing-key">Adding Password to Existing Key</a>
</li>
<li>
<a href="#encryption-and-decryption">Encryption and Decryption</a>
</li>
</ul>
</li>
<li>
<a href="#cli-usage-examples">CLI Usage Examples</a>
<ul>
<li>
<a href="#inline-editing">Inline Editing</a>
</li>
</ul>
</li>
</ul>
</li>
<li>
<a href="#ruby-api">Ruby API</a>
<ul>
<li>
<a href="#encryption-and-decryption-operations">Encryption and Decryption Operations</a>
</li>
<li>
<a href="#full-application-api">Full Application API</a>
</li>
<li>
<a href="#configuration">Configuration</a>
</li>
</ul>
</li>
<li>
<a href="#encryption-features--cipher-used">Encryption Features &amp; Cipher Used</a>
</li>
<li>
<a href="#development">Development</a>
<ul>
<li>
<a href="#contributing">Contributing</a>
</li>
</ul>
</li>
<li>
<a href="#license">License</a>
</li>
<li>
<a href="#acknowledgements">Acknowledgements</a>
</li>
</ul>
<hr />

### Motivation

The primary goal of this tool is to streamline and simplify handling of relatively sensitive data in the most trasparent and easy to use way as possible, without sacrificing security.

Most common use-cases include:

 * __Encrypting/decrypting of application secrets__, so that the encrypted secrets can be safely checked into the git repository and distributed, and yet without much of the added headache that this often requires
 * __Secure message transfer between any number of receipients__
 * __General purpose encryption/decryption with a single encryption key__, optionally itself re-encrypted with a password.

__Sym__ is a layer built on top of the [`OpenSSL`](https://www.openssl.org/) library, and, hopefully, makes encryption more accessible to every-day developers, QA, and dev-ops folks, engaged in deploying applications.

### What's Included

This gem includes two primary components:

 * [Ruby API](#ruby-api) for enabling encryption/decryption of any data within any Ruby class, with extremely easy-to-use methods
 * [Rich command line interface CLI](#cli) with many additional features to streamline handling of encrypted data.

_Symmetric Encryption_ simply means that we are using the same private key to encrypt and decrypt. In addition to the private key, the encryption uses an IV vector. The library completely hides `iv` generation from the user, and automatically generates a random `iv` per encryption.

### How It Works

  1. You start with a piece of sensitive __data__ you want to protect. This can be a file or a string.
  2. You generate a new encryption key, that will be used to both encrypt and decrypt the data. The key is 256 bits, or 32 bytes, or 45 bytes when base64-encoded, and can be generated with `sym -g`.
     * You can optionally password protect the key with `sym -gp`
     * You can save the key into a file `sym -gp -o key-file` 
     * Or you can save it into the OS-X Keychain, with `sym -gp -x keychain-name`
     * or you can print it to STDOUT, which is the default.
  3. You can then use the key to encrypt sensitive __data__, with `sym -e [key-option] [data-option]`, passing it the key in several accepted ways:
     * You can pass the key as a string (not recommended) via `-k key`
     * Or read the key from a file `-K key-file`
     * Or read the key from the OS-X Keychain with `-x keychain-name`
     * Or you can paste the key interactively with `-i` 
  4. Input data can be read from a file with `-f file`, or read from STDIN, or a passed on the command line with `-s string`    
  4. Output is the encrypted data, which is printed to STDOUT by the default, or it can be saved to a file with `-o <file>`
  5. Encrypted file can be later decrypted with `sym -d [key-option] [data-option]`

Sample session that uses Mac OS-X Keychain to store the password-protected key.

```bash
❯ sym -gpx my-new-key
New Password     :  •••••••••
Confirm Password :  •••••••••
BAhTOh1TeW06OkRhdGE6OldyYXBwZXJTdH.....

❯ sym -ex my-new-key -s 'My secret data' -o secret.enc
Coin::Vault listening at: druby://127.0.0.1:24924
Password: •••••••••

❯ cat secret.enc
BAhTOh1TeW06OkRhdGE6OldyYXBFefDFFD.....

❯ sym -dx my-new-key -f secret.enc
My secret data
```

The line that says `Coin::Vault listening at: druby://127.0.0.1:24924` is the indication that the local dRB server used for caching passwords has been started. Password caching can be easily disabled with `-P` flag. In the example above, the decryption step fetched the password from the cache, and so the user was not required to re-enter the password.

__Direct Editing Encrypted Files__

Instead of decrypting data anytime you need to change it, you can use the shortcut flag `-t` (for "edi__T__"), which decrypts your data into a temporary file, automatically opening it with an `$EDITOR`. 

Example:

    sym -t -f config/application/secrets.yml.enc -K ~/.key
    
> This is one of those time-saving features that can make a difference in making encryption feel easy and transparent.

For more information see the section on [inline editing](#inline).

## Installation

If you plan on using the library in your Ruby project with Bundler managing its dependencies, just include the following line in your `Gemfile`:

    gem 'sym'

And then run `bundle`.

Or install it into the global namespace with `gem install` command:

    $ gem install sym
    $ sym -h
    $ sym -E # see examples

__BASH Completion__

Optionally, after gem installation, you can also install bash-completion of gem's command line options, but running the following command (and feel free to use any of the "dot" files you prefer):

    sym --bash-completion ~/.bashrc

Should you choose to install it (this part is optional), you will be able to use "tab-tab" after typing `sym`, and you'll be able to choose from all of the supported flags.

<a name="#cli"></a>

## Using `sym` with the Command Line

### Private Keys

The private key is the cornerstone of the symmetric encryption. Using `sym`, the key can be:

 * generated and printed to STDOUT, or saved to Mac OS-X KeyChain or a file
 * fetched from the Keychain in subsequent operations
 * password-protected during generation (or import) with the `-p` flag.
 * must be kept very well protected and secure from attackers.

The __unencrypted private__ key will be in the form of a base64-encoded string, 45 characters long.

__Encrypted (with password) private key__ will be considerably longer, perhaps 200-300 characters long.

When the private key is encrypted, `sym` will request the password only once per 15 minute period. The password is cached using a local dRB server, but this caching can be disabled with `-P` flag.

#### Generating Private Keys

Let's generate a new key, and copy it to the clipboard (using `pbcopy` command on Mac OS-X):

    sym -g | pbcopy

Or save a new key into a bash variable

    KEY=$(sym -g)

Or save it to a file:

    sym -g -o ~/.key
    sym -go ~/.key

Or create a password-protected key (`-p`), and save it to a file (`-o`), and skip printing the new key to STDOUT (`-q` for quiet):

    sym -gpqo ~/.secret
    New Password:     ••••••••••
    Confirm Password: ••••••••••

You can subsequently use the private key by passing either:

 1. the `-k key-string` flag
 2. the `-K key-file` flag
 3. the `-x key-keychain-name` flag to read the key from Mac OS-X KeyChain
 4. pasting or typing the key with the `-i` (interactive) flag

#### Using KeyChain Access on Mac OS-X

KeyChain storage is a huge time saver. It allows you to securely store the key the keychain, meaning the key can not be easily extracted by an attacker without a login to your account. Just having access to the disk is not enough.

Apple had released a `security` command line tool, which this library uses to securely store a key/value pair of the key name and the actual private key in your OS-X KeyChain. The advantages of this method are numerous:

 * The private key won't be lying around your file system unencrypted, so if your Mac is ever stolen, you don't need to worry about the keys running wild.
 * If you sync your keychain with the iCloud you will have access to it on other machines

To activate the KeyChain mode on the Mac, use `-x <key-name>` field instead of `-k` or `-K`, and add it to `-g` when generating a key. The `key name` is what you call this particular key, based on how you plan to use it. For example, you may call it `staging`, etc.

The following command generates the private key and immediately stores it in the KeyChain access under the name provided:

    sym -g -x staging

Now, whenever you need to encrypt something you can specify the key with `-x staging`. 

Finally, you can delete a key from KeyChain access by running:

    keychain <name> delete

Below we describe the purpose of the executable `keychain` shipped with sym.

#### KeyChain Key Management

`keychain` is an additional executable installed with the gem, which can be used to read (find), update (add), and delete keychain entries used by `sym`. 

It's help message is self-explanatory:

    Usage: keychain <name> [ add <contents> | find | delete ]

#### Moving a Key to the Keychain

You can easily move an existing key from a file or a string to a keychain by combining -k or -K to read the key, with -x to write it.

    sym -k $mykey -x mykey

#### Adding Password to Existing Key

You can add a password to a key by combining one of the key description flags (-k, -K, -i) and then also -p. 

    sym -k $mykey -p -x moo
    
The above example will take an unencrypted key passed in `$mykey`, ask for a password and save password protected key into the keychain with name "moo."

#### Encryption and Decryption

This may be a good time to take a look at the full help message for the `sym` tool, shown naturally with a `-h` or `--help` option.

```
Sym (2.1.1) – encrypt/decrypt data with a private key

Usage:
   # Generate a new key:
   sym -g [ -p ] [ -x keychain ] [ -o keyfile | -q | ]

   # Encrypt/Decrypt
   sym [ -d | -e ] [ -f <file> | -s <string> ]
        [ -k key | -K keyfile | -x keychain | -i ]
        [ -o <output file> ]

   # Edit an encrypted file in $EDITOR
   sym -t -f <file> [ -b ][ -k key | -K keyfile | -x keychain | -i ]

Modes:
  -e, --encrypt                       encrypt mode
  -d, --decrypt                       decrypt mode
  -t, --edit                          decrypt, open an encr. file in an $EDITOR

Create a new private key:
  -g, --generate                      generate a new private key
  -p, --password                      encrypt the key with a password
  -x, --keychain           [key-name] add to (or read from) the OS-X Keychain
  -M, --password-timeout   [timeout]  when passwords expire (in seconds)
  -P, --no-password-cache             disables caching of key passwords

Read existing private key from:
  -i, --interactive                   Paste or type the key interactively
  -k, --private-key        [key]      private key as a string
  -K, --keyfile            [key-file] private key from a file

Data to Encrypt/Decrypt:
  -s, --string             [string]   specify a string to encrypt/decrypt
  -f, --file               [file]     filename to read from
  -o, --output             [file]     filename to write to

Flags:
  -b, --backup                        create a backup file in the edit mode
  -v, --verbose                       show additional information
  -T, --trace                         print a backtrace of any errors
  -D, --debug                         print debugging information
  -q, --quiet                         silence all output
  -V, --version                       print library version
  -N, --no-color                      disable color output

Utility:
  -a, --bash-completion    [file]     append shell completion to a file

Help & Examples:
  -E, --examples                      show several examples
  -h, --help                          show help
```

### CLI Usage Examples

__Generating the Key__:

Generate a new private key into an environment variable:

    export KEY=$(sym -g)
    echo $KEY
    # => 75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4=

Generate a new password-protected key & save to a file:

    sym -gpqo ~/.key
    New Password     : ••••••••••
    Confirm Password : ••••••••••

Encrypt a plain text string with a key, and save the output to a file:

    sym -e -s "secret string" -k $KEY -o file.enc
    cat file.enc
    # => Y09MNDUyczU1S0UvelgrLzV0RTYxZz09CkBDMEw4Q0R0TmpnTm9md1QwNUNy%T013PT0K

Decrypt a previously encrypted string:

    sym -d -s $(cat file.enc) -k $KEY
    # => secret string

Encrypt a file and save it to `sym.enc`:

    sym -e -f app-sym.yml -o app-sym.enc -k $KEY

Decrypt an encrypted file and print it to STDOUT:

    sym -df app-sym.enc -k $KEY

<a name="inline"></a>

#### Inline Editing

The `sym` CLI tool supports one particularly interesting mode, that streamlines handling of encrypted files. The mode is called __edit mode__, and is activated with the `-t` flag. 

In this mode `sym` can decrypt the file, and open the result in an `$EDITOR`. Once you make any changes, and save it (exiting the editor), `sym` will automatically diff the new and old content, and if different – will save encrypt it and overwrite the original file.

> NOTE: this mode does not seem to work with GUI editors such as Atom or TextMate. Since `sym` waits for the editor process to complete, GUI editors "complete" immediately upon starting a windowed application. 
In this mode several flags are of importance:

    -b (--backup)   – will create a backup of the original file
    -v (--verbose) - will show additional info about file sizes

Here is a full command that opens a file specified by `-f | --file`, using the key specified in `-K | --keyfile`, in the editor defined by the `$EDITOR` environment variable (or if not set – defaults to `/bin/vi`)".

To edit an encrypted file in `$EDITOR`, while asking to paste the key (`-i | --interactive`), while creating a backup file (`-b | --backup`):

    sym -tibf data.enc
    # => Private Key: ••••••••••••••••••••••••••••••••••••••••••••
    #
    # => Diff:
    # 3c3
    # # (c) 2015 Konstantin Gredeskoul.  All rights reserved.
    # ---
    # # (c) 2016 Konstantin Gredeskoul.  All rights reserved.

<a name="#ruby-api"></a>

## Ruby API

To use this library, you must include the main `Sym` module into your library.

Any class including `Sym` will be decorated with new class methods `#private_key` and `#create_private_key`, as well as instance methods `#encr`, and `#decr`.

`#create_private_key` will generate a new key each time it's called, while `#private_key` will either assign an existing key (if a value is passed) or generate and save a new key in the class instance variable. Therefore each class including `Sym` will use its key (unless the key is assigned).

The following example illustrates this point:

```ruby
require 'sym'

class TestClass
  include Sym
end
@key = TestClass.create_private_key
@key.eql?(TestClass.private_key)  # => false
# A new key was created and saved in #private_key accessor.

class SomeClass
  include Sym
  private_key TestClass.private_key
end

@key.eql?(SomeClass.private_key)  # => true (it was assigned)
```

### Encryption and Decryption Operations

So how would we use this library from another Ruby project to encrypt and decrypt values?

After including the `Sym` module in a ruby class, the class will now have the `#encr` and `#decr` instance methods, as well as `#secret` and `#create_private_key class methods.

Therefore you could write something like this below, protecting a sensitive string using a class-level secret.

```ruby
require 'sym'
class TestClass
  include Sym
  private_key ENV['SECRET']

  def sensitive_value=(value)
    @sensitive_value = encr(value, self.class.private_key)
  end
  def sensitive_value
    decr(@sensitive_value, self.class.private_key)
  end
end
```

### Full Application API

Since the command line interface offers more than just encryption/decryption, it is available via `Sym::Application` class.

The class is instantiated with a hash that would be otherwise generated by `Slop.parse(argv)` – ie, typical `options`.

Here is an example:

```ruby
require 'sym/application'

key  = Sym::Application.new(generate: true).execute
# => returns a new private key
```

### Configuration

The library offers a typical `Sym::Configuration` class which can be used to tweak some of the internals of the gem. Its meant for an advanced user who knows what he or she is doing. The code snippet shown below is an actual part of the Configuration class, but you can override it by including it in your code that uses and initializes this library, right after the `require.` The `Configuration` class is a Singleton, so changes to it will propagate to any subsequent calls to the gem.

```ruby
require 'zlib'
require 'sym'
Sym::Configuration.configure do |config|
  config.password_cipher = 'AES-128-CBC'  #
  config.data_cipher = 'AES-256-CBC'
  config.private_key_cipher = config.data_cipher
  config.compression_enabled = true
  config.compression_level = Zlib::BEST_COMPRESSION
end
```

As you can see, it's possible to change the default cipher type, although not all ciphers will be code-compatible with the current algorithm, and may require additional code changes.

## Encryption Features & Cipher Used

The `sym` executable as well as the Ruby API provide:

 * Symmetric data encryption with:
   * the Cipher `AES-256-CBC` used by the US Government
   * 256-bit private key, that
     *  can be generated and is a *base64-encoded* string about 45 characters long. The *decoded* key is always 32 characters (or 256 bytes) long.
     * can be optionally password-encrypted using the 128-bit key, and then be automatically detected (and password requested) when the key is used
     * can have its password cached for 15 minutes locally on the machine using dRB server (or used without the cache with `-P` flag).
 * Rich command line interface with some innovative features, such as inline editing of an encrypted file, using your favorite `$EDITOR`.
 * Data handling:
   * Automatic compression of the data upon encryption
   * Automatic base64 encryption to make all encrypted strings fit onto a single line.
   * This makes the format suitable for YAML or JSON configuration files, where only the values are encrypted.
 * Rich Ruby API
 * (OS-X Only): Ability to create, add and delete generic password entries from the Mac OS-X KeyChain, and to leverage the KeyChain to store sensitive private keys.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/kigster/sym](https://github.com/kigster/sym).

## License

`Sym` library is &copy; 2016-2017 Konstantin Gredeskoul.

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

The library is designed to be a layer on top of [`OpenSSL`](https://www.openssl.org/), distributed under the [Apache Style license](https://www.openssl.org/source/license.txt).

## Acknowledgements

[Konstantin Gredeskoul](http:/kig.re) is the primary developer of this library. Contributions from others are strongly encouraged and very welcome. Any pull requests will be reviewed promptly.

Contributors:

 * Wissam Jarjoui (Shippo)
 * Megan Mathews 
 * Barry Anderson

 

