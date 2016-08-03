# RequireDir 

[![Gem Version](https://badge.fury.io/rb/secrets-cipher-base64.svg)](https://badge.fury.io/rb/secrets-cipher-base64)
[![Downloads](http://ruby-gem-downloads-badge.herokuapp.com/secrets-cipher-base64?type=total)](https://rubygems.org/gems/secrets-cipher-base64)

<br />

[![Build Status](https://travis-ci.org/kigster/secrets-cipher-base64.svg?branch=master)](https://travis-ci.org/kigster/warp-dir)
[![Code Climate](https://codeclimate.com/github/kigster/secrets-cipher-base64/badges/gpa.svg)](https://codeclimate.com/githb/kigster/secrets-cipher-base64)
[![Test Coverage](https://codeclimate.com/github/kigster/secrets-cipher-base64/badges/coverage.svg)](https://codeclimate.com/github/kigster/secrets-cipher-base64/coverage)
[![Issue Count](https://codeclimate.com/github/kigster/secrets-cipher-base64/badges/issue_count.svg)](https://codeclimate.com/github/kigster/secrets-cipher-base64)


## Summary

This gem provides an easy way to store application secrets as strings (ie, in YAML or JSON) and be able to quickly decrypt them when they are read, or encrypt them when they are written.

The library simply organizes the code in the discussion here: http://stuff-things.net/2015/02/12/symmetric-encryption-with-ruby-and-rails/ and makes it really easy to use.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'secrets-cipher-base64'
```

And then execute:

    $ bundle

Or install it with `gem` command:

    $ gem install secrets-cipher-base64

## Usage

### Generating a Secret 

The library relies on a secret that must be stored somewhere safely on your local system, for example it can be in the keychain on Mac OSX.

First we must generate the secret we'll use, and store it safely.

__NOTE: never check in the secret into git.__

```ruby
require 'secrets-cipher-base64'

# Generate a secret that you must store in your keychain or somewhere safe.
# NEVER put the secret into your git repo.
 
puts Secrets::Cipher::Secret.new

# Then save the output in your keychain:
# Then when needed to retrieve it, 
```


### Storing the Secret

How you store the secret, is up to you, but here is one way that leverages Mac OS-X Keychain to store the key. In fact you can store multiple keys if you like. In the example below we'll store two seperate secrets, one for staging and one for production:

In your terminal, type these two commands. Note that the `-s` parameter is something you might want to customize, and make it easy to find. For example, instead of using `production` you could use `big-corp-django-secret-production`. The name should be such that it's easy to find once you open KeyChain Editor later.


```bash
security add-generic-password -a $USER -D "secret-cipher-base64" -s "staging"
security add-generic-password -a $USER -D "secret-cipher-base64" -s "production"
```

This step does not actually store any key, it simply creates a KeyChain placeholder for it. We'll generate and add the key next.

Finally, to make this a bit more efficient, I recommend listing the key names in an environment variable set in your `~/.bashrc` file, for example:

```bash
# ~/.bashrc
declare -a secret_names=(production staging)
```

After declaring this array, you can even rewrite the above command as a loop, which could be handy if you are storing not 2 or 3 but 10+ keys.

```bash
for secret_name in ${secret_names[@]}; do
  security add-generic-password -a $USER \ 
      -D "secret-cipher-base64" -s $secret_name
done
```

### Generate Secrets
 
Generating secret is easy with this library. Once the gem is installed you will be able to run an executable `secrets-cipher-base64`:

```bash
secrets-cipher-base64 --generate-secret | pbcopy
```

(if you installed the gem with bundler, make sure to prefix the above command with `bundle exec`).

With the key in your clipboard, let's save it to the KeyChain:
 
### Saving the Secret to KeyChain

* Open `KeyChain Access` application 
* Search for the token you specified, for example `production`
* Double-click on the matching entry
* Click "Show password"
* Paste the copied value in that field
* Click "Save Changes"
* Repeat for `staging` or any other key you want to save.

### Retrieving Secret from the KeyChain

Using the below bash function, you can retrieve and export the secrets as environment variables, which can later be read by your code:

```bash
# append this function to your ~/.bashrc or ~/.bash_profile
function load_secrets() {
  declare -a secret_names=(production staging)
  for secret_name in ${secret_names[@]}; do
    varname="secret_${secret_name}"  # eg, $secret_production 
    secret=`security find-generic-password -g -a $USER -w -D "secret-cipher-base64" -s "$secret_name"`
    eval "export $varname=$secret"
  done
}  
```

With this out of the way, we just need to type `load_secrets` in Terminal to get our keys automatically exported.

### Encrypting Data

```ruby
module CustomLib
  class Encryption
    include Secrets::Cipher::Base64
    secret ENV['secret_production']
    
    def secure_value=(value)
      @secure_value = encr(value)
    end
    
    def secure_value
      decr(@secure_value)
    end
    
    def save!
      # saves the encrypted version @secure_value
    end
  end
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/secrets-cipher-base64.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Author

This library is the work of [Konstantin Gredeskoul](http:/kig.re), &copy; 2016, distributed under the MIT license.

