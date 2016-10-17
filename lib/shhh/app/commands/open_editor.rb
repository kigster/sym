require 'digest'
require 'fileutils'
require 'tempfile'
require 'shhh'
require 'shhh/errors'
require_relative 'command'
module Shhh
  module App
    module Commands
      class OpenEditor < Command
        include Shhh

        required_options [ :private_key, :keyfile, :keychain, :interactive ],
                           :edit,
                           :file

        try_after :generate_key, :encrypt_decrypt

        attr_accessor :tempfile

        def execute
          begin
            self.tempfile = ::Tempfile.new(::Base64.urlsafe_encode64(opts[:file]))
            decrypt_content(self.tempfile)

            result = process launch_editor
          ensure
            self.tempfile.close if tempfile
            self.tempfile.unlink rescue nil
          end
          result
        end

        def launch_editor
          system("#{application.editor} #{tempfile.path}")
        end

        private

        def decrypt_content(file)
          file.open
          file.write(content)
          file.flush
        end

        def content
          @content ||= decr(File.read(opts[:file]), key)
        end

        def timestamp
          @timestamp ||= Time.now.to_a.select { |d| d.is_a?(Fixnum) }.map { |d| '%02d' % d }[0..-3].reverse.join
        end

        def process(code)
          if code == true
            content_edited = File.read(tempfile.path)
            md5            = ::Base64.encode64(Digest::MD5.new.digest(content))
            md5_edited     = ::Base64.encode64(Digest::MD5.new.digest(content_edited))
            return 'No changes have been made.' if md5 == md5_edited

            FileUtils.cp opts[:file], "#{opts[:file]}.#{timestamp}" if opts[:backup]

            diff = compute_diff

            File.open(opts[:file], 'w') { |f| f.write(encr(content_edited, key)) }

            out = ''
            if opts[:verbose]
              out << "Saved encrypted/compressed content to #{opts[:file].bold.blue}" +
                      " (#{File.size(opts[:file]) / 1024}Kb), unencrypted size #{content.length / 1024}Kb."
              out << (opts[:backup] ? ",\nbacked up the last version to #{backup_file.bold.blue}." : '.')
            end
            out << "\n\nDiff:\n#{diff}"
            out
          else
            raise Shhh::Errors::EditorExitedAbnormally.new("#{application.editor} exited with #{$<}")
          end
        end

        # Computes the diff between two unencrypted versions
        def compute_diff
          original_content_file = Tempfile.new(rand(1024).to_s)
          original_content_file.open
          original_content_file.write(content)
          original_content_file.flush
          diff = `diff #{original_content_file.path} #{tempfile.path}`
          diff.gsub!(/> (.*\n)/m, '\1'.green)
          diff.gsub!(/< (.*\n)/m, '\1'.red)
        ensure
          original_content_file.close
          original_content_file.unlink
          diff
        end
      end
    end
  end
end
