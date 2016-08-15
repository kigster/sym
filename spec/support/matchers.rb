

require 'rspec/expectations'

RSpec::Matchers.define :map_to do |expected|
  match do |actual|
    result = Shhh::App::NLP::Translator.new(actual.split(' ')).translate
    result == expected
  end
  failure_message do |actual|
    "Expected transation result to be: ——> #{expected.to_s} but the result was: ——> #{Shhh::App::NLP::Translator.new(actual.split(' ')).translate}"
  end

end

