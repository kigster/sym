require 'active_support/inflector'
require 'tsort'
require 'pp'
module Sym
  module App
    module Commands
      class DependencyResolver < Hash
        include TSort
        alias tsort_each_node each_key

        def tsort_each_child(node, &block)
          fetch(node).each(&block)
        end
      end

      @dependency = DependencyResolver.new
      @commands = Set.new

      class << self
        attr_accessor :commands, :dependency

        def register(command_class)
          self.commands << command_class
          self.dependency[command_class.short_name] ||= []
        end

        def order(command_class, after)
          self.dependency[command_class.short_name].unshift(after) if after
          self.dependency[command_class.short_name].flatten!
        end

        def dependencies
          @dependencies ||= self.dependency.tsort
          @dependencies
        end

        # Sort commands based on the #dependencies array, which itself is sorted
        # based on command dependencies.
        def sorted_commands
          @sorted_commands ||= self.commands.to_a.sort_by{|klass| dependencies.index(klass.short_name) }
          @sorted_commands
        end

        def find_command_class(opts)
          self.sorted_commands.each do |command_class|
            return command_class if command_class.options_satisfied_by?(opts)
          end
          nil
        end
      end
    end
  end
end

require 'sym/app/commands/base_command'
require 'sym/app/commands/bash_completion'
require 'sym/app/commands/encrypt_decrypt'
require 'sym/app/commands/generate_key'
require 'sym/app/commands/keychain_add_key'
require 'sym/app/commands/open_editor'
require 'sym/app/commands/password_protect_key'
require 'sym/app/commands/print_key'
require 'sym/app/commands/show_examples'
require 'sym/app/commands/show_help'
require 'sym/app/commands/show_version'
