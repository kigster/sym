module Secrets
  module App
    module Commands
      class EncryptDecrypt < Command
        include Secrets
        required_options   :private_key,
                         [ :encrypt, :decrypt ],
                         [ :file, :string ]

        def content
          opts[:string] || (opts[:file].eql?('-') ? STDIN.read : File.read(opts[:file]))
        end

        def run
          send(cli.action, content, opts[:private_key])
        end
      end
    end
  end
end
