require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb'].exclude('test/integration/**/*_test.rb')
  t.verbose = true
end

Rake::TestTask.new("test:integration") do |t|
  t.libs << "test"
  t.test_files = FileList['test/integration/**/*_test.rb']
  t.verbose = true
end

task :default => :test
