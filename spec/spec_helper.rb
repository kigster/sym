require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'shhh'
require 'base64'
require 'openssl'

require_relative 'support/contexts'
require_relative 'support/matchers'

RSpec.configure do |spec|

  spec.before do
    Shhh::App.exit_code = 0
  end

end
