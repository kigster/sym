require_relative 'cli'
require_relative 'nlp/constants'
require_relative 'nlp/usage'
require_relative 'nlp/translator'
module Sym
  module App
    #     sym generate key to the clipboard and keychain
    #     sym encrypt file 'hello' using $key [to output.enc]
    #     sym edit 'passwords.enc' using $key
    #     sym decrypt /etc/secrets encrypted with $key save to ./secrets
    #     sym encrypt file $input with keychain $item
    module NLP
      class Base
        extend Usage
      end
    end
  end
end
