module Shhh
  module App
    module Output
      class File
        attr_accessor :cli

        def initialize(cli)
          self.cli = cli
        end

        def opts
          cli.opts
        end

        def output_proc
          ->(data) {
            ::File.open(opts[:output], 'w') { |f| f.write(data) }
          }
        end
      end
    end
  end
end
