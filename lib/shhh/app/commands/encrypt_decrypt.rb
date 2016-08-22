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

        def execute
          send(application.action, content, application.key)
        end

        private

        def content
          @content ||= (opts[:string] || (opts[:file].eql?('-') ? STDIN.read : File.read(opts[:file])))
        end
      end
    end
  end
end
