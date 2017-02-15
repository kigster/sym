# Change Log

## [HEAD](https://github.com/kigster/sym/tree/HEAD)

[Changes since the last tag](https://github.com/kigster/sym/compare/v2.2.0...HEAD)



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

