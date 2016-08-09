module Secrets
  module App
    module Outputs
      class ToFile
        attr_accessor :cli

        def initialize(cli)
          self.cli = cli
        end

        def opts
          cli.opts
        end

        def output_proc
          ->(data) {
            File.open(opts[:output], 'w') { |f| f.write(data) }
            if opts[:verbose]
              puts %Q\File #{opts[:file].bold.green} (#{File.size(opts[:file])/1024}Kb) has been #{action}ypted.\ + "\n" +
                   %Q\Encrypted version written to #{(opts[:output] || 'STDOUT').bold.green} (#{File.size(opts[:output]) / 1024}Kb)\
            end
          }
        end
      end
    end
  end
end
