require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

def shell(*args)
  puts "running: #{args.join(' ')}"
  system(args.join(' '))
end

task :permissions do 
  shell("find . -type f -exec chmod o+r,g+r {} \\;")
  shell("find . -type d -exec chmod o+rx,g+rx {} \\;")
end

task :build => :permissions

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = %w(lib/**/*.rb exe/*.rb - README.md LICENSE sym-3.0-cli.md)
  t.options.unshift('--title','"Sym – Symmetric Key Encryption for Your Data"')
  t.after = ->() { exec('open doc/index.html') }
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec


