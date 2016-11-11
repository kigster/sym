require 'sym/errors'

module Sym
  module App
    module Input
      class Handler

        def ask
          retries ||= 0
          prompt('Password: ', :green)
        rescue ::OpenSSL::Cipher::CipherError
          STDERR.puts 'Invalid password. Please try again.'
          retry if (retries += 1) < 3
          nil
        end

        def puts(*args)
          STDERR.puts args
        end

        def prompt(message, color)
          HighLine.new(STDIN, STDERR).ask(message.bold) { |q| q.echo = '•'.send(color) }
        end

        def new_password
          password = prompt('New Password     :  ', :blue)

          raise Sym::Errors::PasswordTooShort.new(
            'Minimum length is 7 characters.') if password.length < 7

          password_confirm = prompt('Confirm Password :  ', :blue)

          raise Sym::Errors::PasswordsDontMatch.new(
            'The passwords you entered do not match.') if password != password_confirm

          password
        end
      end
    end
  end
end
