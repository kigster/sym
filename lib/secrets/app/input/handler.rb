require 'secrets/errors'

module Secrets
  module App
    module Input
      class Handler
        def self.ask
          retries ||= 0
          prompt('Password: ', :green)
        rescue ::OpenSSL::Cipher::CipherError
          STDERR.puts 'Invalid password. Please try again.'
          retry if (retries += 1) < 3
          nil
        end

        def self.prompt(message, color)
          HighLine.new(STDIN, STDERR).ask(message.bold) { |q| q.echo = '•'.send(color) }
        end

        def self.new_password
          password         = prompt('New Password     : ', :blue)
          password_confirm = prompt('Confirm Password : ', :blue)

          raise Secrets::Errors::PasswordsDontMatch.new(
            'The passwords you entered do not match.') if password != password_confirm

          raise Secrets::Errors::PasswordTooShort.new(
            'Minimum length is 7 characters.') if password.length < 7

          password
        end
      end
    end
  end
end
