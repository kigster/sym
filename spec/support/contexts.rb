require 'spec_helper'
require 'secrets'

require_relative 'fake_terminal'

class TestClass
  include Secrets
  private_key '12312asdf0asdf090'  # Use ENV['SECRET'] in prod

  def secure_value=(value)
    @secure_value = encr(value)
  end

  def secure_value
    decr(@secure_value)
  end
end

RSpec.shared_context :test_instance do
  let(:fake_terminal) { Secrets::App::FakeTerminal.instance }
  let(:fake_stdout) { fake_terminal.lines }

  let(:instance) { TestClass.new }
end

RSpec.shared_context :fake_terminal do
  let(:fake_terminal) { Secrets::App::FakeTerminal.instance }
  let(:fake_stdout) { fake_terminal.lines }
  let(:program_output) { fake_stdout.join("\n") }

  def expect_some_output
    expect(fake_stdout).not_to be_nil
    expect(fake_stdout).to be_kind_of(Array)
    expect(fake_stdout.size).to be > 0
  end
end

RSpec.shared_context :encryption do
  include_context :test_instance
  include_context :fake_terminal
end

RSpec.shared_context :abc_classes do
  let(:c_private_key) { 'BOT+8SVzRKQSl5qecjB4tUW1ENakJQw8wojugYQnEHc=' }
  before do
    class AClass
      include Secrets
    end
    class BClass
      include Secrets
    end
    class CClass
      include Secrets
      private_key 'BOT+8SVzRKQSl5qecjB4tUW1ENakJQw8wojugYQnEHc='
    end
  end
end

RSpec.shared_context :commands do
  include_context :fake_terminal

  let(:private_key) { 'zDMFsylyIsu2k3biBm7EXsM2den9rYoXRC7GfBtgUNI=' }
  let(:cli) { Secrets::App::CLI.new(argv) }
  let(:opts) { cli.opts }

  def before_cli_run

  end

  before do
    fake_terminal.clear!
    expect(Secrets::App::Commands).to receive(:find_command_class).and_return(command_class)
    if self.respond_to?(:before_cli_run)
      self.before_cli_run
    end
    cli.print_proc = cli.output_proc = fake_terminal.output_proc
    cli.run
  end

end
