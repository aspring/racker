require 'rubygems'
require 'bundler'
require 'bundler/gem_tasks'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |t|
  # Specify the files we will look at
  t.patterns = ['bin', File.join('{lib}','**', '*.rb')]

  # Do not fail on error
  t.fail_on_error = false
end

require 'yard'
YARD::Rake::YardocTask.new

task default: [:spec]
