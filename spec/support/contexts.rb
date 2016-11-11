require 'sym'
require 'sym/app'

require_relative 'fake_terminal'

TEST_KEY = 'LxRV7pqW5XY5DDcuh128byukvsr3JLGX54v6eKNl8a0='
class TestClass
  include Sym
  private_key TEST_KEY # Use ENV['SECRET'] in prod

  def secure_value=(value)
    @secure_value = encr(value)
  end

  def secure_value
    decr(@secure_value)
  end
end


unless Sym::App::CLI.instance_methods.include?(:old_execute)
  class Sym::App::CLI
    attr_accessor :already_ran
    alias_method :old_execute, :execute

    def execute
      raise ArgumentError.new('CLI already ran this example') if already_ran
      self.already_ran = true
      self.old_execute
    end
  end
end

RSpec.shared_context :test_instance do
  let(:instance) { TestClass.new }
  let(:test_class) { TestClass }
  let(:test_instance) { instance }
  let(:private_key) { TestClass.create_private_key }
end


RSpec.shared_context :console do
  let(:console) { Sym::App::FakeTerminal.new }
  let(:program_output_lines) { console.lines }
  let(:program_output) { program_output_lines.join("\n") }

  before do
    console.clear!
  end

  def expect_some_output(args = [])
    expect(program_output_lines).not_to be_nil
    expect(program_output_lines).to be_kind_of(Array)
    expect(program_output_lines.size).to be > 0
    if args
      args.each_with_index do |argument, index|
        expect(program_output_lines[index]).to (argument.is_a?(Regexp) ? match(argument) : include(argument))
      end
    end
  end
end

RSpec.shared_context :encryption do
  include_context :test_instance
  include_context :console
end

RSpec.shared_context :run_command do
  include_context :encryption

  let(:private_key) { TEST_KEY }
  let(:cli) { Sym::App::CLI.new(argv.reject { |a| a.to_s =~ /verbose|-v/ }) }
  let(:opts) { cli.opts }
  let(:run_cli) { true }
  let(:application) { cli.application }

  after do
    console.clear!
  end

  before do
    console.clear!
    self.before_cli_run if self.respond_to?(:before_cli_run)
    # overwrite output proc on CLI so that we can collect and test the output
    cli.output_proc = console.output_proc unless opts[:quiet]
    cli.execute if run_cli
  end

  def expect_command_to_have(klass:, output: [], option: nil, value: nil, lines: nil)
    expect(opts[option]).to eql(value) if value && option
    expect(cli.already_ran).to be_truthy

    if klass
      klass.is_a?(Symbol) ?
        expect(application.command.send(klass)).to(be_truthy) :
        expect(application.command.class).to(eql(klass))
    end
    expect_some_output output.is_a?(Array) ? output : [output]
    expect(program_output_lines.size).to eql(lines) if lines
  end
end


RSpec.shared_context :commands do
  include_context :run_command

  def before_cli_runs
    expect(Sym::App::Commands).to receive(:find_command_class).and_return(command_class)
  end
end

RSpec.shared_context :abc_classes do
  let(:c_private_key) { 'BOT+8SVzRKQSl5qecjB4tUW1ENakJQw8wojugYQnEHc=' }
  before do
    class AClass
      include Sym
    end
    class BClass
      include Sym
    end
    class CClass
      include Sym
      private_key 'BOT+8SVzRKQSl5qecjB4tUW1ENakJQw8wojugYQnEHc='
    end

  end
end
