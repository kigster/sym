require 'sym'
require 'sym/application'
require 'sym/app/args'

module Sym
  # This class provides a convenience wrapper for opening and reading
  # encrypted files as they were regular files, and then possibly writing
  # changes to them later.

  class EncryptedFile

    include Sym

    attr_reader :application, :file, :key_id, :key_type, :app_args

    def initialize(file:, key_id:, key_type:)
      @file        = file
      @key_id      = key_id
      @key_type    = key_type.to_sym
      @app_args    = { file: file, key_type => key_id, decrypt: true }
      @application = Sym::Application.new(self.app_args)
    end

    def read
      @content = application.execute! unless @content
      @content
    end

    def write
      Sym::Application.new(file: file, key_type => key_id, encrypt: true, output: file).execute
    end
  end
end

