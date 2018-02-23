begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

task :default => [:spec, :rubocop]

begin
  require 'rspec/core/rake_task'
  desc 'Run specs'
  task :spec do
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = './spec/**/*_spec.rb'
    end
  end
rescue LoadError
  desc 'Run RSpec'
  task :spec do
    abort 'Please install the rspec gem to run tests.'
  end
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  desc 'Run rubocop'
  task :rubocop do
    abort 'Please install the rubocop gem to run rubocop.'
  end
end
