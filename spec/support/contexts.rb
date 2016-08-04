require 'spec_helper'

class TestClass
  include Secrets::Cipher::Base64
  secret '12312asdf0asdf090'

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

