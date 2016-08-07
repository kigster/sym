module Secrets
  module Errors
    # Exceptions superclass for this library.
    class Secrets::Errors::Error < StandardError; end

    # No secret has been provided for encryption or decryption
    class SecretIsNotDefined < Secrets::Errors::Error; end

    # This type of data is currently unsupported by the corresponding
    # Secrets::Encrypted::<Data> class. You can always implement your own
    # and provide it to the HashData and ArrayData classes.
    class UnsupportedType < TypeError
      def initialize(unsupported_type)
        super(self.class.error_message(unsupported_type))
      end
      def self.error_message(argument)
        "Type #{argument.respond_to?(:name) ? argument.name : argument} is not supported."
      end
    end

    # Method was called on an abstract class. Override such methods in
    # subclasses, and use subclasses for instantiation of objects.
    class AbstractMethodCalled < ArgumentError
      def initialize(method, message = nil)
        super("Abstract method call, on #{method}" + (message || ''))
      end
    end
  end
end


