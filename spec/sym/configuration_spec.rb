# coding: utf-8
# frozen_string_literal: true
#
# © 2018 Konstantin Gredeskoul (twitter.com/kig)
# https://github.com/kigster
#
#—————————————————————————————————————————————————————————————————————————————require 'rspec'
#
require 'spec_helper'

RSpec.describe ::Sym::Configuration do
  subject(:config) { described_class.config }

  context 'default values from this class' do
    its(:encrypted_file_extension) { should eq 'enc' }
  end

  context 'default values inherited' do
    its(:password_cipher) { should eq 'AES-128-CBC' }
  end

  context 'setting cipher' do
    before { config.password_cipher = 'AES-256-CBC' }
    its(:password_cipher) { should eq 'AES-256-CBC' }
    after { config.reset_to_defaults! }
  end
end
