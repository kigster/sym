require 'sym/app/commands/base_command'
require 'colored2'
module Sym
  module App
    module Commands
      class BashCompletion < BaseCommand

        required_options [:bash_support]
        try_after :generate_key, :open_editor, :encrypt, :decrypt

        def execute
          file = opts[:bash_support]

          out = ''
          Sym::Constants::Bash::Config.each_pair do |key, config|
            script_name = key.to_s
            FileUtils.cp(config[:source], config[:dest])
            out << if File.exist?(file)
                     if File.read(file).include?(config[:script])
                       "#{'OK'.bold.green}, #{file.bold.yellow} already has #{script_name.bold.blue} installed\n"
                     else
                       append_completion_script(file, config[:script])
                       "#{'OK'.bold.green}, appended initialization for #{script_name.bold.blue} to #{file.bold.yellow}\n"
                     end
                   else
                     append_completion_script(file, config[:script])
                     "#{'OK'.bold.green}, created new file #{file.bold.yellow}, added #{script_name.bold.blue} initialization.\n"
                   end
          end
          out + "Please reload your terminal session to activate bash completion and other installed utilities.\n"
        end

        private

        def append_completion_script(file, script)
          File.open(file, 'a') do |fd|
            fd.write(script + "\n")
          end
        end

      end
    end
  end
end
