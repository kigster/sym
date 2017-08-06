source 'https://rubygems.org'

# Specify your gem's dependencies in sym.gemspec
gemspec

gem 'ffi', :platforms => [:mswin, :mingw]
gem 'sym-crypt', path: '/Users/kig/workspace/oss/ruby/sym-crypt'

if RUBY_PLATFORM == 'x86_64-darwin16'
  gem 'coin', git: 'https://github.com/kigster/coin'
end

