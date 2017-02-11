require 'forwardable'
require 'coin'

module Sym
  module App
    module Password
      class CoinProvider

        extend Forwardable
        def_delegators :coin, :read, :write

        attr_accessor :coin

        def initialize
          Coin.uri  = ::Sym::Configuration.config.password_cache_coin_provider[:uri]
          self.coin = Coin
        end
      end
    end
  end
end
