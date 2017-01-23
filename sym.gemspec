# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sym/version'
Gem::Specification.new do |spec|
  spec.name          = 'sym'
  spec.version       = Sym::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = %w(kigster@gmail.com)

  spec.summary       = %q{Easy to use symmetric encryption library & CLI with a strong aes-256-cbc cipher used by the US Government.}

  spec.description = <<-EOF
    Sym is a versatile command line utility and a library, that streamlines access to a 
    symmetric encryption offered by OpenSSL library. Use its rich CLI interface, or the Ruby 
    API to generate a key used for both encryption and decryption. You can 
    additionally password protect the key, and optionally store the key in the named 
    OS-X keychain. Use the key to reliably encrypt, decrypt and re-encrypt your application 
    secrets. Use the -t CLI switch to open an encrypted file in an editor of your choice. 
    Sym uses a symmetric aes-256-cbc cipher with a private key and an IV vector.
  EOF

  spec.homepage      = 'https://github.com/kigster/sym'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.2'
  spec.post_install_message = <<-EOF
Thank you for installing this gem! 

To enable bash command line completion, please run the following 
command, which appends sym's shell completion to the specified file:

  sym --bash-completion ~/.bash_profile 

(or any other shell initialization file of your preference).

Thank you for checking out Sym and happy crypting :)
   -- KG ( github.com/kigster | twitter.com/kig )
EOF
  spec.add_dependency 'colored2', '~> 2.0'
  spec.add_dependency 'slop', '~> 4.3'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'highline', '~> 1.7'
  spec.add_dependency 'coin', '~> 0.1.8'

  spec.add_development_dependency 'codeclimate-test-reporter', '~> 1.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'yard'
end
