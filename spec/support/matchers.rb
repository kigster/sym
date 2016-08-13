

require 'rspec/expectations'

RSpec::Matchers.define :map_to do |expected|
  match do |actual|
    result = Shhh::App::NLP.new(actual.split(' ')).process
    result == expected
  end
end

