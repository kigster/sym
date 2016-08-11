require 'spec_helper'
require 'secrets/app/private_key/detector'

module Secrets
  module App
    module PrivateKey
      RSpec.describe ::Secrets::App::PrivateKey::Detector do
        include_context :encryption

        context :private_key do
          let(:opts) { { private_key: private_key } }
          subject { Detector.new(opts).key }
          it { is_expected.to eql(private_key) }
        end

        context :keyfile do
          let(:tempfile) { Tempfile.new('boo') }
          let(:opts) { { keyfile: tempfile.path } }

          before { tempfile.write(private_key); tempfile.flush }

          subject { Detector.new(opts).key }
          it { is_expected.to eql(private_key) }
        end

        context :interactive do
          let(:tempfile) { Tempfile.new('boo') }
          let(:opts) { { keyfile: tempfile.path } }

          before { tempfile.write(private_key); tempfile.flush }

          subject { Detector.new(opts).key }
          it { is_expected.to eql(private_key) }

        end


      end

    end
  end
end
