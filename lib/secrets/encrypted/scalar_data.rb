require_relative 'abstract_data'

module Secrets
  module Encrypted
    class ScalarData < AbstractData

      def self.supports?(value)
        ScalarTypeMapping.supports?(value)
      end

      def mapping
        ScalarTypeMapping
      end

      def encrypt(secret)
        encr(mapping.encode(data), secret)
      end

      def decrypt(secret)
        mapping.decode(decr(data, secret))
      end

      # Supporting class that provides ability to encode and auto-detect basic
      # data types upon decryption.
      #
      class ScalarTypeMapping
        @types = {}
        class << self
          attr_reader :types

          def add_type(id:, type:, string_to_type_proc:)
            raise ArgumentError.new(
              "Error adding type #{type.name}: id #{id} is already in use.") if identifiers.include?(id)

            raise ArgumentError.new(
              "Identifier must be a single ASCII character, got #{id}"
            ) unless id.is_a?(String) && id =~ /\w/ && id.size == 1

            types[type] = { to_proc: string_to_type_proc, id: id }
          end

          # Returns a unique set of identifiers in current use by registered types.
          def identifiers
            identifiers = Set.new
            types.values.each { |h| identifiers << h[:id] }
          end
        end

        INDICATOR   = "%%"
        DETECT_REGEX= %r{#{INDICATOR}(\w)\.(.*)$}

        class << self
          def class_identifier(data)
            types[data.class] ? types[data.class][:id] : nil
          end

          def supports?(data)
            ScalarTypeMapping::types.keys.include?(data.class)
          end

          def class_to_proc(data)
            types[data.class] ? types[data.class][:to_proc] : nil
          end

          def encode(data)
            "#{INDICATOR}#{class_identifier(data)}.#{data.to_s}"
          end

          def decode(data)
            match = DETECT_REGEX.match(data)
            raise Secrets::Errors::UnsupportedType.new("Unknown Data Type for [#{data}]") unless match && match[1] && match[2]

            identifier     = match[1]
            decrypted_type = types.keys.find { |k| types[k][:id] == identifier }
            raise Secrets::Errors::UnsupportedType.new("scalar identifier '#{identifier}'") unless decrypted_type

            decrypted_data = match[2]
            types[decrypted_type][:to_proc].call(decrypted_data)
          end
        end
      end
    end
  end
end
