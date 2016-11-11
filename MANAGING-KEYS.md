# Managing Private Keys

In this document we discuss several methods of keeping the private keys safe and yet conveniently available when needed. We also note the possible security implications of each method.

We assume that you have some data or files that have been previously encrypted with a 32-byte key using this library, and that you want to be able to access the data easily with your private key, but at the same time not make it too easy for an attacker to find the keys.

## Method 1.<br>Keychain Access on Mac OS-X

How you store the secret, is up to you, but here is one way that leverages Mac OS-X Keychain. In fact you can store multiple keys if you like. In the example below we'll store two separate keys, one for staging and one for production:

In your terminal, type these two commands. Note that the `-s` parameter is something you might want to customize, and make it easy to find. For example, instead of using `production` you could use `big-corp-django-secret-production`. The name should be such that it's easy to find once you open KeyChain Editor later.

```bash
security add-generic-password -a $USER -D "secret-cipher-base64" -s "staging"
security add-generic-password -a $USER -D "secret-cipher-base64" -s "production"
```

This step does not actually store any key, it simply creates a KeyChain placeholder for it. We'll generate and add the key next.

Finally, to make this a bit more efficient, I recommend listing the key names in an array-type environment variable set in your `~/.bashrc` file, for example:

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
 
### Saving the Secret to KeyChain

* Open `KeyChain Access` application 
* Search for the token you specified, for example `production`
* Double-click on the matching entry
* Click "Show password"
* Paste the copied value in that field
* Click "Save Changes"
* Repeat for `staging` or any other key you want to save.

### Retrieving Secret from the KeyChain

Using the below bash function, you can retrieve and export the sym as environment variables, which can later be read by your code:

```bash
# append this function to your ~/.bashrc or ~/.bash_profile
function load_keys() {
  declare -a secret_names=(production staging)
  for secret_name in ${secret_names[@]}; do
    varname="secret_${secret_name}"  # eg, $secret_production 
    secret=`security find-generic-password -g -a $USER -w -D "secret-cipher-base64" -s "$secret_name"`
    eval "export $varname=$secret"
  done
}  
```

With this out of the way, we just need to type `load_keys` in Terminal to get our keys automatically exported.

### Security

In this model, an attacker who obtains login access to your account will be able to quickly examine the local environment to discover one or more private keys already exported.

