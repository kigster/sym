module Secrets
  module Errors
    # Exceptions superclass for this library.
    class Secrets::Errors::Error < StandardError; end

    # No secret has been provided for encryption or decryption
    class NoPrivateKeyFound < Secrets::Errors::Error; end
    class PasswordsDontMatch < Secrets::Errors::Error; end
    class PasswordTooShort < Secrets::Errors::Error; end
    class DataEncodingVersionMismatch< Secrets::Errors::Error; end
    class EditorExitedAbnormally < Secrets::Errors::Error; end
    class InvalidEncodingPrivateKey < Secrets::Errors::Error; end
    class InvalidPasswordPrivateKey < Secrets::Errors::Error; end
    class FileNotFound < Secrets::Errors::Error; end
    class ExternalCommandError < Secrets::Errors::Error; end

    # Method was called on an abstract class. Override such methods in
    # subclasses, and use subclasses for instantiation of objects.
    class AbstractMethodCalled < ArgumentError
      def initialize(method, message = nil)
        super("Abstract method call, on #{method}" + (message || ''))
      end
    end
  end
end


