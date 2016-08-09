require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
#require 'guard/notifiers/terminal_notifier'
RSpec::Core::RakeTask.new(:spec)

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = %w(lib/**/*.rb exe/*.rb - README.md MANAGING-KEYS.md LICENSE)
  t.options.unshift('--title', '"Secrets – Symmetric Key Encryption for Your Data"')
  system('open doc/index.html')
end

task :default => :spec
