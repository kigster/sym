require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'secrets'
require 'base64'
require 'openssl'

require_relative 'support/contexts'
