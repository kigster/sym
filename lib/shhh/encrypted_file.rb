require 'shhh'
require 'shhh/application'
require 'shhh/app/args'

module Shhh
  # This class provides a convenience wrapper for opening and reading
  # encrypted files as they were regular files, and then possibly writing
  # changes to them later.

  class EncryptedFile

    include Shhh

    attr_reader :application, :file, :key_id, :key_type, :app_args

    def initialize(file:, key_id:, key_type:)
      @file        = file
      @key_id         = key_id
      @key_type     = key_type.to_sym
      @app_args    = { file: file, key_type => key_id, decrypt: true }
      @application = Shhh::Application.new(self.app_args)
    end

    def read
      @content = application.execute! unless @content
      @content
    end

    def write
      Shhh::Application.new(file: file, key_type => key_id, encrypt: true, output: file).execute
    end
  end
end

