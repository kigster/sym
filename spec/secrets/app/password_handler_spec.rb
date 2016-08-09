require 'spec_helper'
require 'singleton'

def setup_handler(calls = [])
  calls.each do |hash|
    expect(Secrets::App::PasswordHandler).to receive(:handle_user_input).with(hash[:message], hash[:color]).and_return(hash[:password])
  end
end

module Secrets
  module App

    RSpec.describe Secrets::App::PasswordHandler do
      let(:password) { 'boobooboo' }
      let(:opts) { { password: true } }
      let(:handler) { PasswordHandler.new(opts) }

      context 'entering password' do
        it 'should save user input' do
          setup_handler [{ message: 'Password: ', color: :green, password: password }]
          expect { handler.ask }.to_not raise_error
          expect(handler.password).to eql(password)
        end
      end

      context 'creating new password' do
        context 'passwords dont match' do
          it 'should raise an exception' do
            setup_handler [
                            { message: 'New Password     : ', color: :blue, password: 'right password' },
                            { message: 'Confirm Password : ', color: :blue, password: 'wrong password' }
                          ]
            expect { handler.create }.to raise_error(Secrets::Errors::PasswordsDontMatch)
          end
        end

        context 'password is too short' do
          it 'should raise an exception' do
            setup_handler [
                            { message: 'New Password     : ', color: :blue, password: 'short' },
                            { message: 'Confirm Password : ', color: :blue, password: 'short' }
                          ]
            expect { handler.create }.to raise_error(Secrets::Errors::PasswordTooShort)
          end
        end
        context 'passwords match and are long enough' do
          it 'should raise an exception' do
            setup_handler [
                            { message: 'New Password     : ', color: :blue, password: 'WhatsUpYo' },
                            { message: 'Confirm Password : ', color: :blue, password: 'WhatsUpYo' }
                          ]
            expect { handler.create }.not_to raise_error
            expect(handler.password).to eql('WhatsUpYo')
          end
        end
      end
    end
  end
end
