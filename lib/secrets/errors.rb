module Secrets
  module Errors
    # Exceptions superclass for this library.
    class Secrets::Errors::Error < StandardError; end

    # No secret has been provided for encryption or decryption
    class NoPrivateKeyFound < Secrets::Errors::Error; end

    # Method was called on an abstract class. Override such methods in
    # subclasses, and use subclasses for instantiation of objects.
    class AbstractMethodCalled < ArgumentError
      def initialize(method, message = nil)
        super("Abstract method call, on #{method}" + (message || ''))
      end
    end
  end
end


