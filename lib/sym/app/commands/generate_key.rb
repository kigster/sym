require_relative 'command'
require 'sym/app/keychain'
module Sym
  module App
    module Commands
      class GenerateKey < Command
        include Sym

        required_options :generate

        def execute
          retries         ||= 0
          new_private_key = self.class.create_private_key
          new_private_key = encr_password(new_private_key,
                                          application.input_handler.new_password) if opts[:password]

          clipboard_copy(new_private_key) if opts[:copy]

          Sym::App::KeyChain.new(opts[:keychain], opts).
            add(new_private_key) if opts[:keychain] && Sym::App.is_osx?

          new_private_key
        rescue Sym::Errors::PasswordsDontMatch, Sym::Errors::PasswordTooShort => e
          STDERR.puts e.message.bold
          retry if (retries += 1) < 3
        end

        private

        def clipboard_copy(key)
          require 'clipboard'
          Clipboard.copy(key)
        end
      end
    end
  end
end
