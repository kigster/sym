require 'sym/errors'

module Sym
  module App
    module Input
      class Handler
        attr_accessor :stdin, :stdout, :stderr, :kernel

        def initialize(stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = nil)
          self.stdin  = stdin
          self.stdout = stdout
          self.stderr = stderr
          self.kernel = kernel
        end

        def ask
          retries ||= 0
          prompt('Password: ', :green)
        rescue ::OpenSSL::Cipher::CipherError
          stderr.puts 'Invalid password. Please try again.'
          retry if (retries += 1) < 3
          nil
        end

        def puts(*args)
          stderr.puts args
        end

        def prompt(message, color)
          unless STDIN.isatty && STDIN.tty?
            raise Sym::Errors::CantReadPasswordNoTTY.new('key requires a password, however STDIN is not a TTY')
          end
          highline(message, color)
        end

        def highline(message, color)
          HighLine.new(stdin, stderr).ask(message.bold) { |q| q.echo = '•'.send(color) }
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
