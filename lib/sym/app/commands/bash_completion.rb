# frozen_string_literal: true

require 'sym/app/commands/base_command'
module Sym
  module App
    module Commands
      class BashCompletion < BaseCommand
        required_options [:bash_support]
        try_after :generate_key, :open_editor, :encrypt, :decrypt

        def ok
          ' '.bold.green
        end

        def execute
          file = opts[:bash_support]

          out = ''
          Sym::Constants::Bash::Config.each_pair do |key, config|
            script_name = key.to_s

            # This removes the old version of this file.
            remove_old_version(out, config[:dest])

            if File.exist?(config[:dest]) && File.read(config[:source]) == File.read(config[:dest])
              out << "#{ok} file #{config[:dest].bold.blue} exists, and is up to date.\n"
            else
              FileUtils.cp(config[:source], config[:dest])
              out << "#{ok} installing #{config[:dest].bold.blue}...\n"
            end

            out << if File.exist?(file)
                     if File.read(file).include?(config[:script])
                       "#{ok} BASH script #{file.bold.yellow} already sources #{script_name.bold.blue}.\n"
                     else
                       append_completion_script(file, config[:script])
                       "#{ok} BASH script #{script_name.bold.blue} is now sourced from #{file.bold.yellow}\n"
                     end
                   else
                     append_completion_script(file, config[:script])
                     "#{ok}, created new file #{file.bold.yellow}, added #{script_name.bold.blue} initialization.\n"
                   end
          end
          out << "\nPlease reload your terminal session to activate bash completion\n"
          out << "and other installed BASH utilities.\n"
          out << "\nAlternatively, just type #{"source #{file}".bold.green} to reload BASH.\n"
          out << "Also — go ahead and try running #{'sym -h'.bold.blue} and #{'symit -h'.bold.blue}.\n"
        end

        private

        def append_completion_script(file, script)
          File.open(file, 'a') do |fd|
            fd.write(script + "\n")
          end
        end

        def remove_old_version(out, file)
          if file =~ /\.bash$/
            old_file = file.gsub(/\.bash$/, '')
            if File.exist?(old_file)
              out << "Removing old version — #{old_file.bold.magenta}..."
              FileUtils.rm_f old_file
            end
          end
        end
      end
    end
  end
end
