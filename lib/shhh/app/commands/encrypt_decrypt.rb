require_relative 'command'
module Shhh
  module App
    module Commands
      class EncryptDecrypt < Command
        include Shhh

        required_options [ :private_key, :keyfile, :keychain, :interactive ],
                         [ :encrypt, :decrypt ],
                         [ :file, :string ]

        try_after :generate_key

        def run
          send(cli.action, content, cli.key)
        end

        private

        def content
          @content ||= (opts[:string] || (opts[:file].eql?('-') ? STDIN.read : File.read(opts[:file])))
        end
      end
    end
  end
end
