# Change Log

## [HEAD](https://github.com/kigster/sym/tree/HEAD)

[Changes since the last tag](https://github.com/kigster/sym/compare/v2.7.0...HEAD)

## [v2.8.0](https://github.com/kigster/sym/tree/v2.8.0) (2018-01-05)
[Full Changelog](https://github.com/kigster/sym/compare/v2.7.0...v2.8.0)

Version 2.8.0 with several key changes below:

 - Ensuring that Sym exits with a non-zero code when errors occur
 - Ensuring that coverage, and doc folders are removed before release
 - Adding sym-encrypt() and sym-decrypt() BASH helpers 
 - Major update to `sym.symit` to provide easier access to commands.
 - Cleaning up output of the errors

## [v2.7.0](https://github.com/kigster/sym/tree/v2.7.0) (2017-06-23)
[Full Changelog](https://github.com/kigster/sym/compare/v2.6.3...v2.7.0)

 * Changing -t flag to expect a file argument, removing the need
   for "-f file" in addition to "-t"
 * Adding 'irbtools' to development gems.

## [v2.6.3](https://github.com/kigster/sym/tree/v2.6.3) (2017-03-13)
[Full Changelog](https://github.com/kigster/sym/compare/v2.6.2...v2.6.3)

 * Much faster unit tests thanks to running Aruba tests in-process
 * Better error reporting, and catching the case when STDIN is not a TTY
   and yet password is required to decrypt the key.

## [v2.6.2](https://github.com/kigster/sym/tree/v2.6.2) (2017-03-12)
[Full Changelog](https://github.com/kigster/sym/compare/v2.6.1...v2.6.2)

 * Updating gem description for RubyGems.

## [v2.6.1](https://github.com/kigster/sym/tree/v2.6.1) (2017-03-12)
[Full Changelog](https://github.com/kigster/sym/compare/v2.6.0...v2.6.1)

 * Mostly updating gem descriptions and README

## [v2.6.0](https://github.com/kigster/sym/tree/v2.6.0) (2017-03-12)
[Full Changelog](https://github.com/kigster/sym/compare/v2.5.3...v2.6.0)

 * Added `Sym::MagicFile` API for easy access to encrypted files.
 * Moving output processing into the `Sym::Application` class.

## [v2.5.3](https://github.com/kigster/sym/tree/v2.5.3) (2017-03-11)
[Full Changelog](https://github.com/kigster/sym/compare/v2.5.2...v2.5.3)

 * Added a "\n" to all printouts to STDOUT as long as it's a TTY

## [v2.5.2](https://github.com/kigster/sym/tree/v2.5.2) (2017-03-07)
[Full Changelog](https://github.com/kigster/sym/compare/v2.5.1...v2.5.2)

 * Minor bug fixes around `symit` bash script, and `--bash-support` flag.

## [v2.5.1](https://github.com/kigster/sym/tree/v2.5.0) (2017-03-07)
[Full Changelog](https://github.com/kigster/sym/compare/v2.5.0...v2.5.1)

 * Moved `symit` into `bin/` folder, and now installing it into `~/.sym.symit` with `-B/--bash-support` flag.
 * `symit` now works as a bash function installed together with the completion.
 * Updated `Sym::Constants` module.
 
## [v2.5.0](https://github.com/kigster/sym/tree/v2.5.0) (2017-03-04)
[Full Changelog](https://github.com/kigster/sym/compare/v2.4.3...v2.5.0)

 * Updated README
 * Remove `-M` flag; make `SYM_ARGS` environment be only used when `-A` flag is supplied
 * Change `--bash-completion` to use `-B`
 * Major fix up for sym.completion
## [v2.6.1](https://github.com/kigster/sym/tree/v2.6.1) (2017-03-11)
[Full Changelog](https://github.com/kigster/sym/compare/v2.6.0...v2.6.1)

## [v2.6.0](https://github.com/kigster/sym/tree/v2.6.0) (2017-03-11)
[Full Changelog](https://github.com/kigster/sym/compare/v2.5.3...v2.6.0)

 * Added `Sym::MagicFile` API for easy access to encrypted files.
 * Moving output processing into the `Sym::Application` class.

## [v2.5.3](https://github.com/kigster/sym/tree/v2.5.3) (2017-03-09)
[Full Changelog](https://github.com/kigster/sym/compare/v2.5.2...v2.5.3)

 * Added a "\n" to all printouts to STDOUT as long as it's a TTY

## [v2.5.2](https://github.com/kigster/sym/tree/v2.5.2) (2017-03-06)
[Full Changelog](https://github.com/kigster/sym/compare/v2.5.1...v2.5.2)

 * Minor bug fixes around `symit` bash script, and `--bash-support` flag.

## [v2.5.1](https://github.com/kigster/sym/tree/v2.5.0) (2017-03-06)
[Full Changelog](https://github.com/kigster/sym/compare/v2.5.0...v2.5.1)

 * Moved `symit` into `bin/` folder, and now installing it into `~/.sym.symit` with `-B/--bash-support` flag.
 * `symit` now works as a bash function installed together with the completion.
 * Updated `Sym::Constants` module.
 
## [v2.5.0](https://github.com/kigster/sym/tree/v2.5.0) (2017-03-04)
[Full Changelog](https://github.com/kigster/sym/compare/v2.4.3...v2.5.0)

 * Updated README
 * Remove `-M` flag; make `SYM_ARGS` environment be only used when `-A` flag is supplied
 * Change `--bash-completion` to use `-B`
 * Major fix up for sym.completion
 * New file `exe/symit` for transparently editing secrets
 * Reworked `Sym::Application`, removed `--dictionary`, and simplified argument parsing.
 * Refactored `output_proc` to live in `application`.

## [v2.4.2](https://github.com/kigster/sym/tree/v2.4.2) (2017-03-01)
[Full Changelog](https://github.com/kigster/sym/compare/v2.4.1...v2.4.2)

 * Fixing BASH completion for sym to look for files after `--negate` and
   to auto-complete long options as well.

## [v2.4.1](https://github.com/kigster/sym/tree/v2.4.1) (2017-02-28)
[Full Changelog](https://github.com/kigster/sym/compare/v2.4.0...v2.4.1)

 * Added new feature:   `-n/--negate` to quickly encrypt/decrypt a file to/from *.enc extension; extension is configurable.
 * Refactored `application.opts` to be a hash.
 * Refactored and consolidate key sources via the `Detector` class.
 * Split off `KeySourceCheck` into a separate entity
 * Simplified `Sym::Application`
 * Removed `OrderedHash`
 * Added `key_source` to logging with `-D`
 * New tests.
 * Fixed command ordering bug.
 * Better "default" file handing, only when no options are supplied.

## [v2.4.0](https://github.com/kigster/sym/tree/v2.4.0) (2017-02-27)
[Full Changelog](https://github.com/kigster/sym/compare/v2.3.0...v2.4.0)

 * CLI API changes:
   * Version 2.4.0
   * New behavior: `-k <value>` now attempts to read a file, environment, keychain or a string.
   * Removed `--keyfile / -K` (-k now accepts file)
   * Removed all `require_relative` occurances, replaced with `require`
   * Adding support for the default key file, stored in `~/.sym.key` by default.
   * Moved all constants to `Sym::Constants`
   * Added ability to map legacy (deprecated) flags
   * Auto-disabling color when STDOUT is not a tty
   * Changed Password Cache flags:
     * Replaced `-C` with `-c` (to enable cache)
     * Replaced `-T` with `-u` for timeout
     * Replaced `-P` with `-r` for provider
   * Changed `-A` (trace) to `-T`
   * Now adding password to the cache upon generation
   * Adding `KeyChain.get` method
   * Replacing private key `Detector` with `Reader`
   * Adding logger
   * Fixing handling of STDIN and STDOUT with pipes
   * Deleting unused files

## [v2.3.0](https://github.com/kigster/sym/tree/v2.3.0) (2017-02-23)
[Full Changelog](https://github.com/kigster/sym/compare/v2.2.1...v2.3.0)
 
 * Improving output, especially as it pertains to error reporting
 * Split encrypt_decrypt command into encrypt and decrypt
 * Fix permissions before `rake build`
 * Improve Yard Doc by moving `Kernel` and `Object` monkey-patching
   into `lib/sym/extensions/stdlib.rb`
 
## [v2.2.1](https://github.com/kigster/sym/tree/v2.2.1) (2017-02-15)
[Full Changelog](https://github.com/kigster/sym/compare/v2.2.0...v2.2.1)

* [`53bb95f`](https://github.com/kigster/sym/commit/53bb95f) Ability to read flags from SYM_ARGS environment
* [`c3d0b86`] (https://github.com/kigster/sym/commit/c3d0b86) Switched to using bash-completion-style syntax
* [`9368bf5`] (https://github.com/kigster/sym/commit/9368bf5) Adding CHANGELOG.md

## [v2.2.0](https://github.com/kigster/sym/tree/v2.2.0) (2017-02-14)
[Full Changelog](https://github.com/kigster/sym/compare/v2.1.2...v2.2.0)

**API CHANGE**:

* Turn off password caching by default, enable with `-C`
* `-P < memcached | drb >` specifies caching mechanism

**Changes:**

* [`b470245`](https://github.com/kigster/sym/commit/b470245/) Turn off password caching by default, enable with `-C`, timeout with `-T`
* [`ca3a903`](https://github.com/kigster/sym/commit/ca3a903/) Adding -C flag
* [`949b2ae`](https://github.com/kigster/sym/commit/949b2ae/) Updating README
* [`513f849`](https://github.com/kigster/sym/commit/513f849/) Adding MemCached provider; ability to specify provider with `-P`
* [`571e668`](https://github.com/kigster/sym/commit/571e668/) Split up Coin off to a cache provider
* [`7afeccc`](https://github.com/kigster/sym/commit/7afeccc/) Better messaging when password server times out
* [`cf226f9`](https://github.com/kigster/sym/commit/cf226f9/) Implement fast timeout for password caching providers, fixes [\#3](https://github.com/kigster/sym/issues/3)

**Closed Issues:**

- make sure drb is not already running/handle exception [\#3](https://github.com/kigster/sym/issues/3)



## [v2.1.2](https://github.com/kigster/sym/tree/v2.1.2) (2017-02-11)
[Full Changelog](https://github.com/kigster/sym/compare/v2.1.1...v2.1.2)

* [`dce9b05`](https://github.com/kigster/sym/commit/dce9b05/) Updating gems summary/desription; bump version 2.1.2
* [`ba60592`](https://github.com/kigster/sym/commit/ba60592/) Adding TOC
* [`7b04ea9`](https://github.com/kigster/sym/commit/7b04ea9/) Updating README for the gem;
* [`52efdb4`](https://github.com/kigster/sym/commit/52efdb4/) Updating the 3.0 usage

## [v2.1.1](https://github.com/kigster/sym/tree/v2.1.1) (2017-02-05)
[Full Changelog](https://github.com/kigster/sym/compare/v2.1.0...v2.1.1)

* [`d503c1c`](https://github.com/kigster/sym/commit/d503c1c/) Fix bug with -E flag exploding; version 2.1.1

## [v2.1.0](https://github.com/kigster/sym/tree/v2.1.0) (2017-01-23)
[Full Changelog](https://github.com/kigster/sym/compare/v2.0.3...v2.1.0)

* [`a7f3239`](https://github.com/kigster/sym/commit/a7f3239/) Proposed CLI for version 3.0
* [`3a706ce`](https://github.com/kigster/sym/commit/3a706ce/) Rename Command to BaseCommand; use require
* [`77936ee`](https://github.com/kigster/sym/commit/77936ee/) Existing keys can be password-prot, and keychained

## [v2.0.3](https://github.com/kigster/sym/tree/v2.0.3) (2017-01-22)
[Full Changelog](https://github.com/kigster/sym/compare/v2.0.2...v2.0.3)

* [`342ecb7`](https://github.com/kigster/sym/commit/342ecb7/) Disable some checks.
* [`984ec27`](https://github.com/kigster/sym/commit/984ec27/) Adding CHANGELOG.
* [`4fc7983`](https://github.com/kigster/sym/commit/4fc7983/) Removing clipboard copy feature: its easy enough.
* [`4f38aa5`](https://github.com/kigster/sym/commit/4f38aa5/) Removing unnecessary file.
* [`4ff0412`](https://github.com/kigster/sym/commit/4ff0412/) Updating README with latest help
* [`787116c`](https://github.com/kigster/sym/commit/787116c/)  rm NLP module, rm keychain del, add bash-comp.
* [`bf70e30`](https://github.com/kigster/sym/commit/bf70e30/) Update repo token

## [v2.0.2](https://github.com/kigster/sym/tree/v2.0.2) (2017-01-21)
[Full Changelog](https://github.com/kigster/sym/compare/v2.0.1...v2.0.2)

* [`c586299`](https://github.com/kigster/sym/commit/c586299/) Better gem description; Bump version

## [v2.0.1](https://github.com/kigster/sym/tree/v2.0.1) (2017-01-20)
[Full Changelog](https://github.com/kigster/sym/compare/v2.0.0...v2.0.1)

* [`96add73`](https://github.com/kigster/sym/commit/96add73/) Travis teset coverage, etc
* [`8f0209e`](https://github.com/kigster/sym/commit/8f0209e/) Updating README badges
* [`0c6a612`](https://github.com/kigster/sym/commit/0c6a612/) Only use github for coin on OSX
* [`3afe846`](https://github.com/kigster/sym/commit/3afe846/) Fixed a bug with >> redirects adding newline
* [`9409cdb`](https://github.com/kigster/sym/commit/9409cdb/) Fixing bash completion for sym.
* [`7cdb062`](https://github.com/kigster/sym/commit/7cdb062/) Add .ruby-version to gitignore
* [`488cd73`](https://github.com/kigster/sym/commit/488cd73/) Using a fork of coin from github
* [`a13eb55`](https://github.com/kigster/sym/commit/a13eb55/) Adding .DS_Store to .gitignore

## [v2.0.0](https://github.com/kigster/sym/tree/v2.0.0) (2016-11-11)
[Full Changelog](https://github.com/kigster/sym/compare/v1.1.2...v2.0.0)

Commits between version 1.1.2 and 2.0.0 were not tracked in the changelog.

