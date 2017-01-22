**2.1.0** (January 22, 2017)

* Added two sub-commands to handle updating and moving existing keys:
  - adding a password to an existing key
  - adding an existing key to the keychain.
  
To add a password to an existing key: 

> `sym [ -k key | -K keyfile | -i | -x <name> ] -p `

To add existing key to a keychain:  
 
> `sym [ -k key | -K keyfile | -i ] -x <name> `

**2.0.3** (January 22, 2017)

* Removed clipboard copy functionality, as it's easy to achieve with `pbcopy`.
* Removed natural language processing stuff
* Removed `keychain-del` feature
* Refactored bash-completion to install a separate ~/.sym.completion file
* Updated README

**2.0.2** (January 20, 2017)

* Added bash-completion installation
* Fixed a bug where a newline was added to file redirects, making
  redirecting encrypted data or keys unusable.

