require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'shhh'
require 'base64'
require 'openssl'
require 'aruba'

require_relative 'support/contexts'
require_relative 'support/matchers'

RSpec.configure do |spec|
  spec.include Aruba::Api
  spec.before do
    Shhh::App.exit_code = 0
    Shhh::App::Password::Cache.instance.enabled = false
  end

  spec.after :all do
    # TODO: replace Coin with DRb-cache and gracefully shut it down
    `kill $(ps -ef | grep ruby | grep [c]oin | awk '{print $2}') 2>/dev/null`
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

::Dir.glob(::File.expand_path('../support/*.rb', __FILE__)).each { |f| require_relative f }
::Dir.glob(::File.expand_path('../support/**/*.rb', __FILE__)).each { |f| require_relative f }
