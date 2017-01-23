require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class EncryptDecrypt < BaseCommand
        include Sym

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
