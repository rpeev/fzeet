require_relative 'lib/fzeet'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList[
    'test/*_test.rb'
  ]
end

desc 'Build gem'
task :build => [:test] do |t|
  system "gem build fzeet.gemspec"
end

desc 'Push gem'
task :push => [:build] do |t|
  system "gem push fzeet-#{Fzeet::VERSION}.gem"
end

task :default => [:test]

if __FILE__ == $0
  Rake::Task[:default].invoke
end
