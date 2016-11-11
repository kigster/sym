require 'sym'
require 'sym/app'
require 'sym/errors'


module Sym
  module App
    #
    # This class forms and shells several commands that wrap Mac OS-X +security+ command.
    # They provide access to storing generic passwords in the KeyChain Access.
    #
    class KeyChain
      class << self
        attr_accessor :user, :kind, :sub_section

        def configure
          yield self
        end

        def validate!
          raise ArgumentError.new(
            'User is not defined. Either set $USER in environment, or directly on the class.') unless self.user
        end
      end

      configure do
        self.kind        = 'sym'
        self.user        = ENV['USER']
        self.sub_section = 'generic-password'
      end

      attr_accessor :key_name, :opts, :stderr_disabled

      def initialize(key_name, opts = {})
        self.key_name = key_name
        self.opts     = opts
        self.class.validate!
      end

      def add(password)
        execute command(:add, "-U -w '#{password}' ")
      end

      def find
        execute command(:find, ' -g -w ')
      end

      def delete
        execute command(:delete)
      end

      def execute(command)
        command += ' 2>/dev/null' if stderr_disabled
        puts "> #{command.yellow.green}" if opts[:verbose]
        output = `#{command}`
        result = $?
        raise Sym::Errors::KeyChainCommandError.new("Command error: #{result}, command: #{command}") unless result.success?
        output.chomp
      rescue Errno::ENOENT => e
        raise Sym::Errors::KeyChainCommandError.new("Command error: #{e.message}, command: #{command}")
      end

      def stderr_off
        self.stderr_disabled = true
      end

      def stderr_on
        self.stderr_disabled = false
      end

      private

      def command(action, extras = nil)
        out = base_command(action)
        out << extras if extras
        out = out.join
        # Do not actually ever run these commands on non MacOSX
        out = "echo Run this –\"#{out}\", on #{Sym::App.this_os}?\nAre you sure?" unless Sym::App.is_osx?
        out
      end

      def base_command(action)
        [
          "security #{action}-#{self.class.sub_section} ",
          "-a '#{self.class.user}' ",
          "-D '#{self.class.kind}' ",
          "-s '#{self.key_name}' "
        ]
      end
    end
  end
end


#
# Usage: add-generic-password [-a account] [-s service] [-w password] [options...] [-A|-T appPath] [keychain]
#     -a  Specify account name (required)
#     -c  Specify item creator (optional four-character code)
#     -C  Specify item type (optional four-character code)
#     -D  Specify kind (default is "application password")
#     -G  Specify generic attribute (optional)
#     -j  Specify comment string (optional)
#     -l  Specify label (if omitted, service name is used as default label)
#     -s  Specify service name (required)
#     -p  Specify password to be added (legacy option, equivalent to -w)
#     -w  Specify password to be added
#     -A  Allow any application to access this item without warning (insecure, not recommended!)
#     -T  Specify an application which may access this item (multiple -T options are allowed)
#     -U  Update item if it already exists (if omitted, the item cannot already exist)
#
# Usage: find-generic-password [-a account] [-s service] [options...] [-g] [keychain...]
#     -a  Match "account" string
#     -c  Match "creator" (four-character code)
#     -C  Match "type" (four-character code)
#     -D  Match "kind" string
#     -G  Match "value" string (generic attribute)
#     -j  Match "comment" string
#     -l  Match "label" string
#     -s  Match "service" string
#     -g  Display the password for the item found
#     -w  Display only the password on stdout
# If no keychains are specified to search, the default search list is used.
#         Find a generic password item.
#
# Usage: delete-generic-password [-a account] [-s service] [options...] [keychain...]
#     -a  Match "account" string
#     -c  Match "creator" (four-character code)
#     -C  Match "type" (four-character code)
#     -D  Match "kind" string
#     -G  Match "value" string (generic attribute)
#     -j  Match "comment" string
#     -l  Match "label" string
#     -s  Match "service" string
# If no keychains are specified to search, the default search list is used.
#         Delete a generic password item.
