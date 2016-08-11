require 'spec_helper'
require 'singleton'

def setup_handler(calls = [])
  calls.each do |hash|
    expect(Secrets::App::Input::Handler).to receive(:prompt).with(hash[:message], hash[:color]).and_return(hash[:password])
  end
end

module Secrets
  module App

    RSpec.describe Secrets::App::Input::Handler do
      let(:password) { 'boobooboo' }
      let(:opts) { { password: true } }
      let(:handler) { Input::Handler }

      context 'entering password' do
        it 'should save what the stupid user entered' do
          setup_handler [ { message: 'Password: ', color: :green, password: password } ]
          expect { handler.ask }.to_not raise_error
        end
        it 'should be what the stupid user entered' do
          setup_handler [ { message: 'Password: ', color: :green, password: password } ]
          expect(handler.ask).to eql(password)
        end
      end

      context 'creating new password' do
        context 'passwords dont match' do
          it 'should raise an exception' do
            setup_handler [ { message: 'New Password     : ', color: :blue, password: 'right password' },
                            { message: 'Confirm Password : ', color: :blue, password: 'wrong password' } ]
            expect { handler.new_password }.to raise_error(Secrets::Errors::PasswordsDontMatch)
          end
        end

        context 'password is too short' do
          it 'should raise an exception' do
            setup_handler [
                            { message: 'New Password     : ', color: :blue, password: 'short' },
                            { message: 'Confirm Password : ', color: :blue, password: 'short' }
                          ]
            expect { handler.new_password }.to raise_error(Secrets::Errors::PasswordTooShort)
          end
        end
        context 'passwords match and are long enough' do
          it 'should raise an exception' do
            setup_handler [
                            { message: 'New Password     : ', color: :blue, password: 'WhatsUpYo' },
                            { message: 'Confirm Password : ', color: :blue, password: 'WhatsUpYo' }
                          ]
            password = nil
            expect { password = handler.new_password }.not_to raise_error
            expect(password).to eql('WhatsUpYo')
          end
        end
      end
    end
  end
end
