# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sym/version'

Gem::Specification.new do |spec|
  spec.name          = 'sym'
  spec.version       = Sym::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = %w(kigster@gmail.com)

  spec.summary       = %q{Dead-simple and easy to use encryption library on top of OpenSSL, offering rich Ruby API as well as feature-rich CLI able to generate a key, encrypt/decrypt data, password-protect the keys, cache passwords, and more. Strong cipher "aes-256-cbc" used by US Government is behind data encryption.}

  spec.description   = Sym::DESCRIPTION

  spec.homepage      = 'https://github.com/kigster/sym'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.2'
  spec.post_install_message = <<-EOF

Thank you for installing Sym! 

BLOG POST
=========
http://kig.re/2017/03/10/dead-simple-encryption-with-sym.html

BASH COMPLETION
=============== To enable bash command line completion, please run the following 
command, which appends sym's shell completion wrapper to the file 
specified in arguments to -B/--bash-support flag.

  sym -B ~/.bash_profile
  source ~/.bash_profile
 
Thank you for using Sym and happy crypting :)

@kigster on Github, 
    @kig on Twitter.

EOF
  spec.add_dependency 'colored2', '~> 3'
  spec.add_dependency 'slop', '~> 4'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'highline', '~> 1'
  spec.add_dependency 'coin', '~> 0.1.8'
  spec.add_dependency 'dalli', '~> 2'
  spec.add_dependency 'sym-crypt', '~> 1.1.1'

  spec.add_development_dependency 'codeclimate-test-reporter', '~> 1.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'irbtools'
  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
end
