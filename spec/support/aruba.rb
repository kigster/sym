require 'aruba/rspec'
require 'aruba/processes/in_process'
require 'sym/app/cli'

Aruba.configure do |config|
  unless ENV['CI']
    config.command_launcher = :in_process
    config.main_class = Sym::App::CLI
  end
end
