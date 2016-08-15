require_relative 'cli'
require_relative 'nlp/constants'
require_relative 'nlp/usage'
require_relative 'nlp/translator'
module Shhh
  module App
    #     shhh generate key to the clipboard and keychain
    #     shhh encrypt file 'hello' using $key [to output.enc]
    #     shhh edit 'passwords.enc' using $key
    #     shhh decrypt /etc/secrets encrypted with $key save to ./secrets
    #     shhh encrypt file $input with keychain $item
    module NLP
      class Base
        extend Usage
      end
    end
  end
end
