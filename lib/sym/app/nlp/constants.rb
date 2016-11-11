module Sym
  module App
    module NLP
      module Constants
        STRIPPED = %i(and a the it item to key with about for of new make store in print)

        DICTIONARY = {
          # option (Slop)
          #               list of english words that map to it
          :copy        => [:clipboard],
          :decrypt     => [:unlock],
          :edit        => [:open],
          :encrypt     => [:lock],
          :backup      => [],
          :keychain    => [],
          :file        => [:read],
          :generate    => [:create],
          :interactive => [:ask, :enter, :type],
          :keyfile     => [:from],
          :output      => [:save, :write],
          :private_key => [:using, :private],
          :string      => [:value],
          :quiet       => [:silently, :quietly, :silent, :sym],
          :password    => [:secure, :secured, :protected]
        }

      end

    end
  end
end

