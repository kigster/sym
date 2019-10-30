require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'sym'
require 'base64'
require 'openssl'
require 'aruba'
require 'rspec/its'

if File.exist?(Sym::Constants::SYM_KEY_FILE)
  FileUtils.mv(Sym::Constants::SYM_KEY_FILE, Sym::Constants::SYM_KEY_FILE + '.bak')
  Kernel.at_exit do
    FileUtils.mv(Sym::Constants::SYM_KEY_FILE + '.bak', Sym::Constants::SYM_KEY_FILE)
  end
end

require_relative 'support/contexts'
require_relative 'support/shared_examples'
require 'timeout'

RSpec.configure do |spec|
  spec.include Aruba::Api
  spec.before do
    Sym::App.exit_code                         = 0
    Sym::App::Password::Cache.instance.enabled = false
    allow(Sym).to receive(:default_key?).and_return(false)
  end


  RSpec.configure do |c|
    c.around(:each) do |example|
      Timeout::timeout(2) {
        example.run
      }
    end
  end
end

Kernel.class_eval do
  def clear_memcached!
    `echo flush_all | nc -c -G 2 127.0.0.1 11211 2>/dev/null`
    $?.exitstatus == 0
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

::Dir.glob(::File.expand_path('../support/**/*.rb', __FILE__)).each { |f| require f }
