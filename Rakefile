require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'


YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = %w(lib/**/*.rb exe/*.rb - README.md MANAGING-KEYS.md LICENSE)
  t.options.unshift('--title', '"Shhh – Symmetric Key Encryption for Your Data"')
  t.after = ->() { exec('open doc/index.html') }
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
