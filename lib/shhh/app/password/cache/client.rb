require 'drb/drb'
module Shhh
  module App
    module Password
      module Cache
        class Client
          # The URI to connect to

          attr_accessor :uri, :host, :port
          attr_accessor :config

          def initialize(host: nil,
                         port: nil,
                         config: {})
            self.config =config
            self.host   = host
            self.port   = port
          end

          def uri
            return uri if uri
            template = 'druby://<%= host %>:<%= port %>>'
            renderer = ERB.new template
            self.uri = renderer.result(binding)
          end

          def start
            raise NoMethodError, 'not implemented'
            # Start a local DRbServer to handle callbacks.

            # Not necessary for this small example, but will be required
            # as soon as we pass a non-marshallable object as an argument
            # to a dRuby call.

            # Note: this must be called at least once per process to take any effect.
            # This is particularly important if your application forks.
            DRb.start_service
            # timeserver = DRbObject.new_with_uri(SERVER_URI)
            # puts timeserver.get_current_time
            # sleep 10
          end
        end
      end
    end
  end
end
