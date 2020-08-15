require_relative '../lib/ruby_warnings'
require 'simplecov'

SimpleCov.start do
  add_filter %r{^/(spec)/}
end

if ENV['CODECOV_TOKEN'] && !(ARGV.last && File.exist?(ARGV.last))
  require 'codecov'
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Codecov
  ])
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'sym'
require 'base64'
require 'openssl'
require 'aruba'
require 'rspec/its'

if File.exist?(Sym::Constants.sym_key_file)
  FileUtils.mv(Sym::Constants.sym_key_file, Sym::Constants.sym_key_file + '.bak')
  Kernel.at_exit do
    FileUtils.mv(Sym::Constants.sym_key_file + '.bak', Sym::Constants.sym_key_file)
  end
end

require_relative 'support/contexts'
require_relative 'support/shared_examples'

RSpec.configure do |spec|
  spec.include Aruba::Api
  spec.before do
    Sym::App.exit_code                         = 0
    Sym::App::Password::Cache.instance.enabled = false
    allow(Sym).to receive(:default_key?).and_return(false)
  end
end

Kernel.class_eval do
  def clear_memcached!
    `printf "flush_all\\r\\nquit\\r\\n" | nc -G 2 127.0.0.1 11211 2>/dev/null`
    $?.exitstatus == 0
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

::Dir.glob(::File.expand_path('../support/**/*.rb', __FILE__)).each { |f| require f }
