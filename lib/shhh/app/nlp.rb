require_relative 'cli'
module Shhh
  module App
    #     shhh generate key to the clipboard and keychain
    #     shhh encrypt file 'hello' using $key [to output.enc]
    #     shhh edit 'passwords.enc' using $key
    #     shhh decrypt /etc/secrets encrypted with $key save to ./secrets
    #     shhh encrypt file $input with keychain $item

    class NLP
      IGNORED = %i(and the to key with it item about for of from make create)

      MAPPING = { using:     :private_key,
                  from:      :keyfile,
                  lock:      :encrypt,
                  unlock:    :decrypt,
                  save:      :output,
                  clipboard: :copy,
                  ask:       :interactive,
                  enter:     :interactive,
                  read:      :file,
                  write:     :output,
                  silently:  :quiet
      }

      attr_accessor :argv, :result, :cli, :opts

      def initialize(argv)
        self.argv   = argv
        self.cli    = CLI.new(%w(-E))
        self.opts   = cli.opts.to_hash
        self.result = []
      end

      def process
        argv.each do |value|

          arg = MAPPING.key?(value.to_sym) ? MAPPING[value.to_sym] : value.to_sym
          if opts.to_hash.key?(arg)
            result << '--' + "#{arg.to_s.gsub(/_/, '-')}"
          else
            result << arg.to_s unless IGNORED.include?(arg)
          end
        end
        result

      end

      def run
        CLI.new(process).run
      end
    end
  end
end
