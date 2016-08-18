require 'drb/drb'
require 'singleton'
module Shhh
  module App
    module Password
      module Cache
        URI='druby://localhost:8787'

        class Server
          include Singleton

          def lookup(key)
            raise NoMethodError, 'not implemented'
            return 'tasty bisquits'
          end

          FRONT_OBJECT=self.instance

          def boot
            raise NoMethodError, 'not implemented'
            # The object that handles requests on the server

            $SAFE = 1 # disable eval() and friends

            DRb.start_service(URI, FRONT_OBJECT)
            # Wait for the drb server thread to finish before exiting.
            DRb.thread.join
          end
        end
      end
    end
  end
end
