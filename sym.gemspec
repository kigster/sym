# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sym/version'

Gem::Specification.new do |spec|
  spec.name          = 'sym'
  spec.version       = Sym::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = %w(kigster@gmail.com)

  spec.summary       = %q{Flexible, transparent and easy to use symmetric encryption library build on top of OpenSSL offering both a rich Ruby API as well as a feature-rich CLI. Sym is able to generate encryption keys (optionally password-protected), encrypt/decrypt data, optionally cache key passwords for a configurable period. Encryption keys can be stored in the following ways (ordered from the most secure to the least): 1. OS-X Keychain, 2. ENV variable, 3. File path, 4. String passed to the command arguments. The actual encryption uses cipher "aes-256-cbc" selected by the US Government. This gem provides rich interface on top of very basic encryption routines, which are available in the "sister"-gem called 'sym-crypt'. If all you need is to add `encr` and `decr` methods to your Ruby classes, use `sym-crypt` instead.}

  spec.description   = Sym::DESCRIPTION

  spec.homepage      = 'https://github.com/kigster/sym'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.2'
  spec.post_install_message = <<-EOF
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│ Thank you for installing Sym — Symmetric Encryption Made Easy!                                  │
│   Versions:                                                                                     │
│     Sym #{Sym::VERSION}                                                                      │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│   • For help run sym -h and sym -E                                                              │
│   • See also gem sym-crypt at https://github.com/kigster/sym-crypt                              │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
EOF
  spec.add_dependency 'colored2'
  spec.add_dependency 'slop', '~> 4.3'
  spec.add_dependency 'sym-crypt', '>= 1.2.0'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'highline'
  spec.add_dependency 'dalli'

  spec.add_development_dependency 'codeclimate-test-reporter', '~> 1.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'irbtools'
  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'yard'
end
