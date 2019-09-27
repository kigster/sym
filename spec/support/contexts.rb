require 'sym'
require 'sym/app'

require_relative 'fake_terminal'

TEST_KEY = 'LxRV7pqW5XY5DDcuh128byukvsr3JLGX54v6eKNl8a0='

class TestClass
  include Sym
  private_key TEST_KEY

  def sensitive_value=(value)
    @encrypted_value = encr(value)
  end

  def decrypted_sensitive_value
    decr(@encrypted_value)
  end
end

def verify_program_argument(argument, program_output_line)
  if argument.is_a?(Regexp)
    expect(program_output_line).to match(argument)
  else
    expect(program_output_line).to include(argument)
  end
end

def expect_some_output(output_lines, args = [])
  expect(output_lines).not_to be_nil
  expect(output_lines).to be_a_kind_of(Array)
  expect(output_lines.size).to be > 0
  if args
    args.each_with_index do |argument, index|
      verify_program_argument(argument, output_lines[index])
    end
  end
end

def expect_command_to_have(klass:,
                           output: [],
                           option: nil,
                           value: nil,
                           lines: nil,
                           program_output: [])
  expect(opts[option]).to eql(value) if value && option
  puts output
  puts program_output
  if klass
    klass.is_a?(Symbol) ?
      expect(application.command.send(klass)).to(be_truthy) :
      expect(application.command.class).to(eql(klass))
  end

  expect_some_output program_output, (output.is_a?(Array) ? output : [output])
  expect(program_output.size).to eql(lines) if lines
end
#
# unless Sym::App::CLI.instance_methods.include?(:old_execute)
#   class Sym::App::CLI
#     attr_accessor :already_ran
#     alias_method :old_execute, :execute
#
#     def execute
#       raise ArgumentError.new('CLI already ran this example') if already_ran
#       self.already_ran = true
#       self.old_execute
#     end
#   end
# end

RSpec.shared_context :test_instance do
  let(:test_class) { TestClass }
  let(:test_instance) { TestClass.new }
  let(:key) { TEST_KEY }

  before { TestClass.private_key(TEST_KEY) }
end

RSpec.shared_context :console do
  let(:console) { Sym::App::FakeTerminal.instance }

  before { console.clear! }
  after { console.clear! }

  let(:program_output_lines) { console.lines }
  let(:program_output) { program_output_lines.join("\n") }
end

RSpec.shared_context :encryption do
  include_context :test_instance
  include_context :console
end

RSpec.shared_context :cli do
  include_context :encryption

  let(:cli_class) { Sym::App::CLI }
  let(:cli) { cli_class.new(argv) }
  let(:opts) { cli.opts }
  let(:application) { cli.application }

  before { expect(opts).to_not be_empty }
end

RSpec.shared_context :run_command do
  include_context :cli

  after { console.clear! }

  before do
    console.clear!

    self.before_cli_run if self.respond_to?(:before_cli_run)
    # overwrite output proc on CLI so that we can collect and test the output\
    cli.output_proc console.output_proc unless opts[:quiet]
    begin
      cli.execute
    rescue StandardError => e
      STDERR.puts "ERROR at cli.execute():\n#{e.inspect.bold.red}"
    end
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
