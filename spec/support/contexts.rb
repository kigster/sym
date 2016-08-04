require 'spec_helper'

class TestClass
  include Secrets::Cipher::Base64
  secret '12312asdf0asdf090'

  attr_accessor :first, :last, :phone
  attr_encrypted :first, :last
end

RSpec.shared_context :module_included do
  let(:test_instance) { TestClass.new }
end

