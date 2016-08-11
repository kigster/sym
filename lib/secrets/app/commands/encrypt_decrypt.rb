require_relative 'command'
module Secrets
  module App
    module Commands
      class EncryptDecrypt < Command
        include Secrets

        required_options [ :private_key, :keyfile, :keychain, :interactive ],
                         [ :encrypt, :decrypt ],
                         [ :file, :string ]

        def run
          send(cli.action, content, opts[:private_key])
        end

        private

        def content
          @content ||= (opts[:string] || (opts[:file].eql?('-') ? STDIN.read : File.read(opts[:file])))
        end
      end
    end
  end
end
