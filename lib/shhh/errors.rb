module Shhh
  # All public exceptions of this library are here.
  module Errors
    # Exceptions superclass for this library.
    class Shhh::Errors::Error < StandardError; end

    # No secret has been provided for encryption or decryption
    class InsufficientOptionsError < Shhh::Errors::Error; end

    class PasswordError < Shhh::Errors::Error; end
    class PasswordsDontMatch < Shhh::Errors::PasswordError; end
    class PasswordTooShort < Shhh::Errors::PasswordError; end

    class EditorExitedAbnormally < Shhh::Errors::Error; end

    class FileNotFound < Shhh::Errors::Error; end

    class DataEncodingVersionMismatch< Shhh::Errors::Error; end

    class KeyError < Shhh::Errors::Error; end
    class InvalidEncodingPrivateKey < Shhh::Errors::KeyError; end
    class InvalidPasswordPrivateKey < Shhh::Errors::KeyError; end
    class NoPrivateKeyFound < Shhh::Errors::KeyError; end

    class KeyChainCommandError < Shhh::Errors::Error; end

    # Method was called on an abstract class. Override such methods in
    # subclasses, and use subclasses for instantiation of objects.
    class AbstractMethodCalled < ArgumentError
      def initialize(method, message = nil)
        super("Abstract method call, on #{method}" + (message || ''))
      end
    end
  end
end


