require 'forwardable'
require 'coin'

module Sym
  module App
    module Password
      class CoinProvider

        URI = 'druby://127.0.0.1:24924'

        extend Forwardable
        def_delegators :coin, :read, :write

        attr_accessor :coin

        def initialize(*args, **opts, &block)
          Coin.uri  = Sym::App::Password::CoinProvider::URI
          self.coin = Coin
        end
      end
    end
  end
end
