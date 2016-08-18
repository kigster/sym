require_relative 'command'
require 'shhh/app/keychain'
module Shhh
  module App
    module Commands
      class GenerateKey < Command
        include Shhh

        required_options :generate

        def run
          retries         ||= 0
          new_private_key = self.class.create_private_key

          if opts[:password]
            new_private_key = encr_password(new_private_key,
                                            cli.input_handler.new_password)
          end

          clipboard_copy(new_private_key) if opts[:copy]

          if opts[:keychain] && Shhh::App.is_osx?
            Shhh::App::KeyChain.new(opts[:keychain], opts).add(new_private_key)
          end

          new_private_key
        rescue Shhh::Errors::PasswordsDontMatch, Shhh::Errors::PasswordTooShort => e
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
