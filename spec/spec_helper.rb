require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'sym'
require 'base64'
require 'openssl'
require 'aruba'
require 'rspec/its'

require_relative 'support/contexts'
require_relative 'support/shared_examples'

RSpec.configure do |spec|
  spec.include Aruba::Api
  spec.before do
    Sym::App.exit_code                         = 0
    Sym::App::Password::Cache.instance.enabled = false
    allow(Sym).to receive(:default_key?).and_return(false)
  end

  spec.after :all do
    `/usr/bin/env bash -c "kill $(ps -ef | egrep ruby | egrep [c]oin | awk '{print $2}' ) 2>/dev/null"`
    `echo flush_all | nc -G 2 127.0.0.1 11211 2>/dev/null`
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

::Dir.glob(::File.expand_path('../support/*.rb', __FILE__)).each { |f| require_relative f }
::Dir.glob(::File.expand_path('../support/**/*.rb', __FILE__)).each { |f| require_relative f }
