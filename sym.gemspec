# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sym/version'

Gem::Specification.new do |spec|
  spec.name          = 'sym'
  spec.version       = Sym::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = %w(kigster@gmail.com)

  spec.summary       = %q{Super easy to use encryption library & a CLI with a strong aes-256-cbc cipher that can be used to transparently encrypt/decrypt/edit application secrets.}

  spec.description   = Sym::DESCRIPTION

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
  spec.add_dependency 'colored2', '~> 3'
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
