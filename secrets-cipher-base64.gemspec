# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'secrets/version'

Gem::Specification.new do |spec|
  spec.name          = 'secrets-cipher-base64'
  spec.version       = Secrets::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = %w(kigster@gmail.com)

  spec.summary       = %q{Store application secrets encrypted as strings, and read/write using symmetric aes-256-cbc encryption/decryption with a secret key and an IV vector}
  spec.description   = %q{Store application secrets encrypted as strings, and read/write using symmetric aes-256-cbc encryption/decryption with a secret key and an IV vector}
  spec.homepage      = 'https://github.com/kigster/secrets-cipher-base64'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'require_dir'
  spec.add_dependency 'colored2'
  spec.add_dependency 'slop'
  spec.add_dependency 'hashie'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'irbtools'
end
