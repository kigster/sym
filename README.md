# Sym — Light Weight Symmetric Encryption for Humans

[![Gem Version](https://badge.fury.io/rb/sym.svg)](https://badge.fury.io/rb/sym)
[![Downloads](http://ruby-gem-downloads-badge.herokuapp.com/sym?type=total)](https://rubygems.org/gems/sym)
[![Documentation](http://inch-ci.org/github/kigster/sym.png)](http://inch-ci.org/github/kigster/sym)

[![Build Status](https://travis-ci.org/kigster/sym.svg?branch=master)](https://travis-ci.org/kigster/sym)
[![Code Climate](https://codeclimate.com/github/kigster/sym/badges/gpa.svg)](https://codeclimate.com/github/kigster/sym)
[![Test Coverage](https://codeclimate.com/github/kigster/sym/badges/coverage.svg)](https://codeclimate.com/github/kigster/sym/coverage)
[![Issue Count](https://codeclimate.com/github/kigster/sym/badges/issue_count.svg)](https://codeclimate.com/github/kigster/sym)

## Description

### Summary

> __sym__ is a utility and an API that makes it _trivial to encrypt and decrypt sensitive data_. Unlike many other existing tools, __sym__'s goal is to dramatically simplify the command line interface (CLI), and make symmetric encryption as routine as listing directories in Terminal.

With this tool I wanted to make it easy to memorize the most common options, so that there is little no longer a barrier to the full power of encryption offered by [`OpenSSL`](https://www.openssl.org/) library.

And no tool works in isolation: this is just a stepping stone that could be part of your deployment or infrastructure code: don't rely on external services: minimize the risk of a "man-in-the-middle" attack, by dealing with the encryption and decryption locally. Ideal application of this gem, is the ability to store sensitive application _secrets_ protected on a file system, or in a repo, and use `sym` to automaticaly decrypt the data when any changes are to be made, or when the data needs to be read by an application service.

And finally, in addition to the rich CLI interface of the `sym` executable, there is a rich and extensibe symmetric encryption API that can be easily used from any ruby project.

### How It Works

  1.  You start with a piece of sensitive data, say it's called _X_.
  2.  _X_ is  currently a file on your file system, unencrypted.
  2. You use __sym__ (with `-g` — for "generate")  to make a new encryption key. The key is 256 bits, or 32 bytes, or 45 bytes when base64-encoded.
  3. You must save this key somewhere safe. We'll talk about this further.
  4. You use __sym__ (with `-e`) to encrypt _X_ with the key, and save into _Y_.
  5. You now delete _X_ from your file system. You now only have _Y_ and the _key_.
  7. To read the data back, you use __sym__ with the `-d` (for "decrypt") to decrypt _Y_ back. You can print the contents or save it again.
  8. But, instead of just decrypting it, you can use the `-t` mode (for "ediT"), which would decrypt _Y_ into _X_, save _X_ into a temporary location, and allow you to edit the unencrypted file using `$EDITOR`. Once you save and exit the editor, a new version is automatically encrypted and replaces the old version, showing you the diff and, optionally, creating a backup.

### Features

The `sym` executable as well as the Ruby API provide:

 * Symmetric data encryption with:
   * the cipher `AES-256-CBC` used by the US Government
   * 256-bit private key
     *  which can be auto-generated, and is a *base64-encoded* string which is 45 characters long. The *decoded* secret is always 32 characters long (or 256 bytes long).
     * which can be optionally password-encrypted using 128-bit key.
       * which is automatically detected when the key is read
 * Rich command line interface with some innovative features, such as inline  editing of an encrypted file, using your favorite `$EDITOR`.
 * Data handling:
   * Automatic compression of the data upon encryption
   * Automatic base64 encryption to make all encrypted strings fit onto a single line.
   * This makes the format suitable for YAML or JSON configuration files, where only the values are encrypted.
 * Rich Ruby API
 * (OS-X Only): Ability to create, add and delete generic password entries from the Mac OS-X KeyChain, and to leverage the KeyChain to store sensitive private keys.

### Symmetric Encryption

Symmetric encryption simply means that we are using the same private key to encrypt and decrypt.
In addition to the private key, the encryption uses an IV vector. The library completely hides `iv` from the user, generates one random `iv` per encryption, and stores it together with the field itself (*base64-encoded*).

## Installation

If you plan on using the library in your ruby project with Bundler managing its dependencies, just include the following line in your `Gemfile`:

    gem 'sym'

And then run `bundle`.

Or install it into the global namespace with `gem install` command:

    $ gem install sym
    $ sym -h
    $ sym -E # see examples

### BASH Completion (Optional Step)

After gem installation, an message will tell you to install bash completion into to your `~/.bashrc` or equivalent:

```bash
sym --bash-completion ~/.bashrc
```

Should you choose to install it (this part is optional), you will be able to use "tab-tab" after typing `sym` and you'll be able to choose from all supported flags.

## Usage

### Private Keys

This library relies on the existance of the 32-byte private key (aka, *a secret*) to perform encryption and decryption.

The key can be easily:

 * generated by this gem and displayed, or saved to Mac OS-X KeyChain
 * one way or another must be kept very well protected and secure from attackers
 * can be fetched from the the Keychain in subsequent encryption/decryption steps
 * password-protected, which you can enable during the generation with the `-p` flag.
   * NOTE: right now there is no way to add a password to an existing key, only generate a new one.

Unencrypted private key will be in the form of a base64-encoded string, 45 characters long.

Encrypted private key will be considerably longer, perhaps 200-300 characters long.

When the private key is encrypted, `sym` will request the password every time it is used. We are looking at adding a caching layer with a configuerable timeout, so that the password is only re-entered once per given period.

### Command Line (CLI)

You can generate using the command line, or in a programmatic way. First we'll discuss the command line usage, and in a later section we'll discuss Ruby API provided by the gem.

#### Generating and Using Private Keys

Once the gem is installed you will be able to run an executable `sym`. Now let's generate and copy the new private key to the clipboard (using `pbcopy` command on Mac OS-X):

    sym -g | pbcopy

Or save a new key into a bash variable

    SECRET=$(sym -g)

Or save it to a file:

    sym -go ~/.key

Or create a password-protected key, and save it to a file:

    sym -gcp -o ~/.secret
    # New Password:     ••••••••••
    # Confirm Password: ••••••••••

You can subsequently use the private key by either:

1. passing the `-k [key value]` flag
2. passing the `-K [key file]` flag3.
3. pasting or typing the key with the `-i` (interactive) flag
4. passing the `-x [keychain access entry name]` flag to read from Mac OS-X KeyChain Access's generic password field.

#### Using KeyChain Access on Mac OS-X

On Mac OS-X there is a third option – using the Keychain Access Manager behind the scenes. Apple released a `security` command line tool, which this library uses to securely store a key/value pair of the key name and the actual private key in your OS-X KeyChain. The advantages of this method are numerous:

 * The private key won't be lying around your file system unencrypted, so if your Mac is ever stolen, you don't need to worry about the keys running wild.
 * If you sync your keychain with iCloud you will have access to it on other machines

To activate the KeyChain mode on the Mac, use `-x <keyname>` field instead of `-k` or `-K`, and add it to `-g` when generating a key. The `keyname` is what you name this particular key base on where it's going to be used. For example, you may call it `staging`, etc.

The following command generates the private key and immediately stores it in the KeyChain access under the name provided:

    sym -g -x staging

Now, whenever you need to encrypt something, in addition to the `-k` and `-K` you can also choose `-x staging`. This will retrieve the key from the KeyChain access, and use it for encryption/decryption.

Finally, you can delete a key from KeyChain access by running:

    sym --keychain-del staging

#### KeyChain Key Management

Another tiny executable supplied with this library is called `keychain`

```bash
Usage: keychain item [ add <contents> | find | delete ]
```
You can use this to add an existing key that can be used with the `sym` later. Of course you can also use the tool to find or delete it.

####  Encryption and Decryption

This may be a good time to take a look at the full help message for the `sym` tool, shown naturally with a `-h` or `--help` option.

```
Sym (2.0.2) – encrypt/decrypt data with a private key

Usage:
   # Generate a new key:
   sym -g [ -c ] [ -p ] [ -x keychain ] [ -o keyfile | -q | ]  

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
  -q, --quiet                         silence all output
  -V, --version                       print library version
  -N, --no-color                      disable color output
 
Utility:
  -a, --bash-completion    [file]     append shell completion to a file
 
Help & Examples:
  -E, --examples                      show several examples
  -L, --language                      natural language examples
  -h, --help                          show help
```

### CLI Usage Examples

__Generating the Key__:

Generate a new private key into an environment variable:

    export KEY=$(sym -g)
    echo $KEY
    # => 75ngenJpB6zL47/8Wo7Ne6JN1pnOsqNEcIqblItpfg4=

Generate a new password-protected key & save to a file:

    sym -gp -o ~/.key
    New Password     : ••••••••••
    Confirm Password : ••••••••••

Encrypt a plain text string with a key, and save the output to a file:

    sym -e -s "secret string" -k $KEY -o file.enc
    cat file.enc
    # => Y09MNDUyczU1S0UvelgrLzV0RTYxZz09CkBDMEw4Q0R0TmpnTm9md1QwNUNy%T013PT0K

Decrypt a previously encrypted string:

    sym -d -s $(cat file.enc) -k $KEY
    # => secret string

Encrypt a file and save it to sym.enc:

    sym -e -f app-sym.yml -o app-sym.enc -k $KEY

Decrypt an encrypted file and print it to STDOUT:

    sym -df app-sym.enc -k $KEY

##### Inline Editing

The `sym` CLI tool supports one interesting mode where you can open an encrypted file in an `$EDITOR`, and edit it's unencrypted version (stored temporarily in a temp file), and upon saving and exiting the gem will automatically diff the new and old content, and if different – will save encrypt it and overwrite the original file.

In this mode several flags are of importance:

    -b (--backup)   – will create a backup of the original file
    -v (--verbose) - will show additional info about file sizes

Here is a full command that opens a file specified by `-f | --file`, using the key specified in `-K | --keyfile`, in the editor defined by the `$EDITOR` environment variable (or if not set – defaults to `/bin/vi`)".

NOTE: while much effort has been made to ensure that the gem is bug free, the reality is that no software is bug free. Please make sure to backup your encrypted file before doing it for the first few times to get familiar with the command.

To edit an encrypted file in $EDITOR, while asking to paste the key (`-i | --interactive`), while creating a backup file (`-b | --backup`):

    sym -tibf data.enc
    # => Private Key: ••••••••••••••••••••••••••••••••••••••••••••
    #
    # => Diff:
    # 3c3
    # # (c) 2015 Konstantin Gredeskoul.  All rights reserved.
    # ---
    # # (c) 2016 Konstantin Gredeskoul.  All rights reserved.

### Ruby API

To use this library you must include the main `Sym` module into your library.

Any class including `Sym` will be decorated with new class methods `#private_key` and `#create_private_key`, as well as instance methods `#encr`, and `#decr`.

`#create_private_key` will generate a new key each time it's called, while `#private_key` will either assign an existing key (if a value is passed), or generate and save a new key in the class instance variable. Therefore each class including `Sym` will use it's own key (unless the key is assigned).

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

#### Encryption and Decryption

So how would we use this library from another ruby project to encrypt and decrypt values?

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

#### Full Application API

Since the command line interface offers more than just encryption/decryption, it is available via `Sym::Application` class.

The class is instantiated with a hash that would be otherwise generated by `Slop.parse(argv)` – ie, typical `options`.

Here is an example:

```ruby
require 'sym/application'

key  = Sym::Application.new(generate: true).execute
# => returns a new private key
```

### Configuration

The library offers a typical `Sym::Configuration` class which can be used to tweak some of the internals of the gem. This is really meant for a very advanced user who knows what she is doing. The following snippet is actually part of the Configuration class itself, but can be overridden by your code that uses and initializes this library. `Configuration` is a singleton, so changes to it will propagate to any subsequent calls to the gem.

```ruby
require 'zlib'
Sym::Configuration.configure do |config|
  config.password_cipher = 'AES-128-CBC'  #
  config.data_cipher = 'AES-256-CBC'
  config.private_key_cipher = config.data_cipher
  config.compression_enabled = true
  config.compression_level = Zlib::BEST_COMPRESSION
end
```

As you can see, it's possible to change the default cipher typem, although not all ciphers will be code-compatible with the current algorithm, and may require additional code changes.

## Managing Keys

There is a separate discussion about ways to securely store private keys in [MANAGING-KEYS.md](https://github.com/kigster/sym/blob/master/MANAGING-KEYS.md).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at (https://github.com/kigster/sym)[https://github.com/kigster/sym].

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Author

This library is the work of [Konstantin Gredeskoul](http:/kig.re), &copy; 2016-2017, distributed under the MIT license.

