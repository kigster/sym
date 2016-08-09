require 'secrets/errors'

module Secrets
  module App
    class PasswordHandler
      attr_accessor :opts, :password

      def initialize(opts)
        self.opts = opts
      end

      def ask
        retries       ||= 0
        self.password = self.class.handle_user_input('Password: ', :green)
      rescue ::OpenSSL::Cipher::CipherError
        STDERR.puts 'Invalid password. Please try again.'
        retry if (retries += 1) < 3
      end

      def self.handle_user_input(message, color)
        HighLine.new(STDIN, STDERR).ask(message.bold) { |q| q.echo = '•'.send(color) }
      end

      def create
        if opts[:password]
          self.password    = self.class.handle_user_input('New Password     : ', :blue)
          password_confirm = self.class.handle_user_input('Confirm Password : ', :blue)

          raise Secrets::Errors::PasswordsDontMatch.new(
            'The passwords you entered do not match.') if password != password_confirm

          raise Secrets::Errors::PasswordTooShort.new(
            'Minimum length is 7 characters.') if password.length < 7
        end
        self
      end
    end
  end
end
