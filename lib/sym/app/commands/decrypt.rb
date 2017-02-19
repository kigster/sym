require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class Decrypt < BaseCommand
        include Sym

        required_options [ :private_key, :keyfile, :keychain, :interactive ],
                         [ :decrypt ],
                         [ :file, :string ]

        try_after :generate_key, :show_version

        def execute
          send(application.action, content, application.key)
        end
      end
    end
  end
end
