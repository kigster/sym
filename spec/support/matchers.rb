

require 'rspec/expectations'

RSpec::Matchers.define :map_to do |expected|
  match do |actual|
    @translator =  Sym::App::NLP::Translator.new(actual.split(' ')).translate
    @translator.translated_argv == expected
  end
  failure_message do |actual|
    "Expected transation result to be: ——> #{expected.to_s} but the result was: ——> #{@translator.translated_argv}"
  end

end

