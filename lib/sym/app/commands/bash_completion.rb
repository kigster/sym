require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class BashCompletion < BaseCommand

        required_options [:bash_completion]
        try_after :generate_key, :open_editor, :encrypt, :decrypt

        def execute
          install_completion_file
          file = opts[:bash_completion]
          if File.exist?(file)
            if File.read(file).include?(script)
              "#{'Hmmm'.bold.yellow}: #{file.bold.yellow} had completion for #{'sym'.bold.red} already installed\n"
            else
              append_completion_script(file)
              "#{'OK'.bold.green}: appended completion for #{'sym'.bold.red} to #{file.bold.yellow}\n"
            end
          else
            append_completion_script(file)
            "#{'OK'.bold.green}: created new file #{file.bold.yellow} and installed BASH completion for #{'sym'.bold.red}\n"
          end
        end

        private

        def install_completion_file
          FileUtils.cp(source_file, path)
        end

        def append_completion_script(file)
          File.open(file, 'a') do |fd|
            fd.write(script)
          end
        end


        def script
          Sym::Constants::Completion::Config[:script]
        end

        def source_file
          Sym::Constants::Completion::Config[:file]
        end

        def path
          Sym::Constants::Completion::PATH
        end

      end
    end
  end
end
