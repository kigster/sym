require 'spec_helper'
require 'secrets'

class TestClass
  include Secrets
  secret '12312asdf0asdf090'  # Use ENV['SECRET'] in prod

  def secure_value=(value)
    @secure_value = encr(value)
  end

  def secure_value
    decr(@secure_value)
  end
end

RSpec.shared_context :module_included do
  let(:test_instance) { TestClass.new }
end

