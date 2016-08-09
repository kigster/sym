require 'active_support/inflector'

module Secrets
  module App
    module Commands
      class << self
        attr_accessor :commands
      end

      self.commands = Set.new

      class << self
        def find_command_class(opts)
          self.commands.each do |command_class|
            return command_class if command_class.options_satisfied_by?(opts.to_hash)
          end
          nil
        end

        def register(command_class)
          self.commands << command_class
        end
      end
    end
  end
end

