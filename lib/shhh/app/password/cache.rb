module Shhh
  module App
    module Password
      module Cache
        SERVER = {
          host: '127.0.0.1',
          port: 8787
        }
      end
    end
  end
end

Shhh.dir_r 'shhh/app/password'
