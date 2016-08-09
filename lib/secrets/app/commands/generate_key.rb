require_relative 'command'
module Secrets
  module App
    module Commands
      class GenerateKey < Command
        include Secrets

        required_options :generate

        def run
          retries         ||= 0
          new_private_key = self.class.create_private_key

          if opts[:password]
            handler = Secrets::App::PasswordHandler.new(opts).create
            new_private_key = encr_password(new_private_key, handler.password)
          end

          clipboard_copy(new_private_key) if opts[:copy]
          new_private_key
        rescue Secrets::Errors::PasswordsDontMatch, Secrets::Errors::PasswordTooShort => e
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
