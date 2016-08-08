require 'spec_helper'
require 'secrets'

class TestClass
  include Secrets
  private_key '12312asdf0asdf090'  # Use ENV['SECRET'] in prod

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

RSpec.shared_context :abc_classes do
  let(:c_private_key) { 'BOT+8SVzRKQSl5qecjB4tUW1ENakJQw8wojugYQnEHc=' }
  before do
    class AClass
      include Secrets
    end
    class BClass
      include Secrets
    end
    class CClass
      include Secrets
      private_key 'BOT+8SVzRKQSl5qecjB4tUW1ENakJQw8wojugYQnEHc='
    end
  end
end
