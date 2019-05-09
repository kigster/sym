require 'colored2'
require 'base64'
require 'openssl'
require 'aruba'
require 'rspec'
require 'rspec/its'
require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'sym'

require_relative 'support/contexts'
require_relative 'support/shared_examples'

RSpec.configure do |spec|
  spec.run_all_when_everything_filtered = true
  spec.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  spec.order = 'random'

  spec.include Aruba::Api
  spec.before type: :aruba do
    Sym::App.exit_code                         = 0
    Sym::App::Password::Cache.instance.enabled = false
    allow(Sym).to receive(:default_key?).and_return(false)
  end
end

::Dir.glob(::File.expand_path('../support/**/*.rb', __FILE__)).each { |f| require f }
